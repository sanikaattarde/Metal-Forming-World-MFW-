// Group U9: the parts of OP-25 that need no emulator: the input check and the topic name (MOD11-P2-T03).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { checkSendInput } from '../functions/dist/notifications.js';
import { topicFor } from '../functions/dist/pushSender.js';

const GOOD = { request_id: 'r1', category_id: 'notif-new-issues', title: '  A title ', body: ' A body ', target_type: 'none' };

test('U9 a good send is trimmed, and a target of none has no reference', () => {
  assert.deepEqual(checkSendInput(GOOD), {
    invalid: [],
    input: { categoryId: 'notif-new-issues', title: 'A title', body: 'A body', targetType: 'none', targetRef: null },
  });
  assert.deepEqual(checkSendInput({ ...GOOD, target_ref: null }).invalid, []);
});

test('U9 each bad value is named once, sorted, and no value is repeated', () => {
  const { invalid, input } = checkSendInput({ title: 5, body: '', target_type: 'issue', target_ref: 'x/y', extra: '<script>' });
  assert.equal(input, undefined);
  assert.deepEqual(invalid, ['body', 'category_id', 'extra', 'request_id', 'target_ref', 'title']);
});

test('U9 a post reference is a positive whole number written as text', () => {
  for (const ref of ['1', '101', '999999999999']) assert.deepEqual(checkSendInput({ ...GOOD, target_type: 'news_post', target_ref: ref }).invalid, [], ref);
  for (const ref of [101, '0', '-1', '1.5', '01', '1e3', '9999999999999']) {
    assert.deepEqual(checkSendInput({ ...GOOD, target_type: 'news_post', target_ref: ref }).invalid, ['target_ref'], String(ref));
  }
});

test('U9 the topic is the category identifier, and a name the push service would refuse is null', () => {
  assert.equal(topicFor('notif-new-issues'), 'notif-new-issues');
  for (const id of ['with space', 'slash/inside', 'é', '', 'x'.repeat(901)]) assert.equal(topicFor(id), null, id);
});
