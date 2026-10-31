// SPIKE (DEC-003 OPEN, DEC-026 PROPOSED). OP-23 setNewsControl, from API_AND_BACKEND_CONTRACT.md section
// 5.1. The record is public, so it holds no admin identity (INV-12). Marking a post as breaking sends
// nothing: a breaking-news notification is OP-25, which is not built. How a breaking post is shown is OQ-17.
import { FieldValue } from 'firebase-admin/firestore';
import { adminCall } from './adminCall.js';
import { invalidArgument } from './errors.js';
import { isNonEmptyText, unknownFields } from './validation.js';

const FIELDS = new Set(['request_id', 'wp_post_id', 'is_hidden', 'is_breaking']);

export const setNewsControl = adminCall(async ({ db, data }) => {
  const invalid = unknownFields(data, FIELDS);
  if (!isNonEmptyText(data.request_id)) invalid.push('request_id');
  if (!Number.isInteger(data.wp_post_id) || (data.wp_post_id as number) < 1) invalid.push('wp_post_id');
  if (typeof data.is_hidden !== 'boolean') invalid.push('is_hidden');
  if (typeof data.is_breaking !== 'boolean') invalid.push('is_breaking');
  if (invalid.length > 0) throw invalidArgument(invalid.sort());

  const { wp_post_id: postId, is_hidden: isHidden, is_breaking: isBreaking } = data as {
    wp_post_id: number;
    is_hidden: boolean;
    is_breaking: boolean;
  };
  const ref = db.collection('news_controls').doc(String(postId));

  // A record with neither flag set may be removed (DATABASE_AND_DATA_MODEL.md section 4.15).
  if (!isHidden && !isBreaking) await ref.delete();
  else await ref.set({ wp_post_id: postId, is_hidden: isHidden, is_breaking: isBreaking, updated_at: FieldValue.serverTimestamp() });

  return { wp_post_id: postId, is_hidden: isHidden, is_breaking: isBreaking };
});
