// SPIKE (DEC-003 OPEN, DEC-026 PROPOSED). OP-17 saveCategory and OP-18 deleteCategory, from
// API_AND_BACKEND_CONTRACT.md section 5.1. Issue categories only: segments and notification categories
// are seeded by the developers, so OP-28 and OP-29 are not built (GS-Q47, GS-Q56).
import { adminCall } from './adminCall.js';
import { inUse, invalidArgument, nameTaken, notFound } from './errors.js';
import { derivedId, isNonEmptyText, unknownFields } from './validation.js';

// PLACEHOLDER. No document sets a length (DATABASE_AND_DATA_MODEL.md MA-6). Not a decided value.
export const PLACEHOLDER_MAX_CATEGORY_NAME_LENGTH = 200;

const SAVE_FIELDS = new Set(['request_id', 'category_id', 'name', 'display_order']);
const DELETE_FIELDS = new Set(['request_id', 'category_id']);

const nameKey = (name: string) => name.trim().toLowerCase();

export const saveCategory = adminCall(async ({ uid, db, data }) => {
  const invalid = unknownFields(data, SAVE_FIELDS);
  if (!isNonEmptyText(data.request_id)) invalid.push('request_id');
  if (data.category_id !== undefined && !isNonEmptyText(data.category_id)) invalid.push('category_id');
  if (!isNonEmptyText(data.name) || data.name.trim().length > PLACEHOLDER_MAX_CATEGORY_NAME_LENGTH) invalid.push('name');
  if (!Number.isInteger(data.display_order)) invalid.push('display_order');
  if (invalid.length > 0) throw invalidArgument(invalid.sort());

  const editing = data.category_id as string | undefined;
  const id = editing ?? derivedId('category', uid, data.request_id as string);
  const ref = db.collection('categories').doc(id);
  const name = (data.name as string).trim();
  const record = { category_id: id, name, display_order: data.display_order as number };

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (editing && !snap.exists) throw notFound();
    if (!editing && snap.exists) return; // a repeat of the same create

    // The name is unique, ignoring case. How a transaction protects a query result against a record
    // created at the same moment is NOT VERIFIED (TECHNOLOGY_DECISIONS.md section 9.4, item 20).
    const all = await tx.get(db.collection('categories'));
    if (all.docs.some((doc) => doc.id !== id && nameKey(String(doc.get('name'))) === nameKey(name))) throw nameTaken();

    tx.set(ref, record);
  });

  return record;
});

export const deleteCategory = adminCall(async ({ db, data }) => {
  const invalid = unknownFields(data, DELETE_FIELDS);
  if (!isNonEmptyText(data.request_id)) invalid.push('request_id');
  if (!isNonEmptyText(data.category_id)) invalid.push('category_id');
  if (invalid.length > 0) throw invalidArgument(invalid.sort());

  const ref = db.collection('categories').doc(data.category_id as string);

  await db.runTransaction(async (tx) => {
    // A category in use cannot be deleted (DATABASE_AND_DATA_MODEL.md section 4.6).
    const used = await tx.get(db.collection('issues').where('category_id', '==', ref.id).limit(1));
    if (!used.empty) throw inUse();

    // Deleting a category that is already gone changes nothing, so a repeat is harmless.
    tx.delete(ref);
  });

  return { category_id: ref.id, deleted: true };
});
