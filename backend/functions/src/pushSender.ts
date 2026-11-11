// How OP-25 and OP-26 hand a notification to the push service (TD-13, PROPOSED): one topic per notification
// category, and no device token stored by the backend. The real sender is Firebase Cloud Messaging. Push is
// not set up in MFW's accounts yet (MOD11-P2-T01), so nothing here has been sent to a real device.
//
// The emulators have no messaging service. On them a stand-in takes the message, keeps it in a collection
// that only the tests read, and fails when a test asks it to. It refuses to run anywhere else.
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { onEmulators } from './signedLinks.js';

export interface PushMessage {
  topic: string;
  title: string;
  body: string;
  data: Record<string, string>; // send_id, target_type and target_ref: what a tap opens (FR-NOTIF-005)
}

export interface PushSender {
  // Resolves when the push service accepted the message. That is not a delivery receipt.
  send(message: PushMessage): Promise<void>;
}

// A topic name allows letters, digits and "-_.~%" only (Firebase Cloud Messaging's documented pattern).
const TOPIC = /^[A-Za-z0-9\-_.~%]{1,900}$/;

// The topic of a notification category. The data model derives it from category_id (section 4.12); the
// derivation, the name itself, is PROPOSED. The app subscribes a device to the same name.
export function topicFor(categoryId: string): string | null {
  return TOPIC.test(categoryId) ? categoryId : null;
}

export const messagingPushSender: PushSender = {
  async send(message) {
    await getMessaging().send({
      topic: message.topic,
      notification: { title: message.title, body: message.body },
      data: message.data,
    });
  },
};

export const EMULATOR_OUTBOX = 'emulator_push_outbox';
export const EMULATOR_CONTROL = 'emulator_push/control';

export const emulatorPushSender: PushSender = {
  async send(message) {
    if (!onEmulators()) throw new Error('The stand-in push service runs only on the emulators.');
    const db = getFirestore();
    if ((await db.doc(EMULATOR_CONTROL).get()).get('outcome') === 'fail') throw new Error('the stand-in push service failed');
    await db.collection(EMULATOR_OUTBOX).add({ ...message, received_at: FieldValue.serverTimestamp() });
  },
};

export const pushSender = (): PushSender => (onEmulators() ? emulatorPushSender : messagingPushSender);
