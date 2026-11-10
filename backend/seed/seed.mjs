// The seed definitions and their loader (MOD13-P1-T10, GAP-03). Emulators only.
// On the working position the developers set three fixed notification categories (GS-Q47, PROPOSED).
// OQ-18 and CFG-13 are OPEN. The segment list waits for OQ-13 and is not seeded.
import { readFileSync } from 'node:fs';

export const SEED = JSON.parse(readFileSync(new URL('./notification-categories.json', import.meta.url), 'utf8'));

const TOP_LEVEL = new Set(['about', 'notification_categories']);
// NOTIFICATION_CATEGORY, DATABASE_AND_DATA_MODEL.md section 4.12.
const FIELDS = ['category_id', 'display_order', 'is_active', 'name'];
// The push topic name is derived from the identifier (section 4.12; TD-13). Lower-case words joined by
// hyphens is PROPOSED, narrower than a document key needs.
const IDENTIFIER = /^[a-z0-9]+(-[a-z0-9]+)*$/;

const isRecord = (value) => typeof value === 'object' && value !== null && !Array.isArray(value);

// Every problem with the seed, so that one run names them all. An empty list means it is usable.
export function seedProblems(seed) {
  if (!isRecord(seed)) return ['the seed is not an object'];

  const problems = [];
  const unknown = Object.keys(seed).filter((key) => !TOP_LEVEL.has(key));
  if (unknown.length > 0) problems.push(`unknown top-level keys: ${unknown.sort().join(', ')}`);
  if (seed.about !== undefined && typeof seed.about !== 'string') problems.push('about is not text');

  const list = seed.notification_categories;
  if (!Array.isArray(list) || list.length === 0) return [...problems, 'notification_categories is not a list with entries'];

  const ids = new Set();
  const names = new Set();
  const orders = new Set();
  list.forEach((entry, index) => {
    const at = `notification_categories[${index}]`;
    if (!isRecord(entry)) {
      problems.push(`${at} is not an object`);
      return;
    }
    if (Object.keys(entry).sort().join() !== FIELDS.join()) problems.push(`${at} must have exactly ${FIELDS.join(', ')}`);

    const { category_id: id, name, display_order: order, is_active: active } = entry;
    if (typeof id !== 'string' || !IDENTIFIER.test(id)) problems.push(`${at}.category_id is not lower-case words joined by hyphens`);
    else if (ids.has(id)) problems.push(`${at}.category_id repeats ${id}`);
    ids.add(id);

    // The name is unique, ignoring case (section 4.12).
    if (typeof name !== 'string' || name.trim() === '') problems.push(`${at}.name is empty`);
    else if (name !== name.trim()) problems.push(`${at}.name has spaces at an end`);
    else if (names.has(name.toLowerCase())) problems.push(`${at}.name repeats, ignoring case`);
    if (typeof name === 'string') names.add(name.toLowerCase());

    // A unique order is PROPOSED, so that the list has one order.
    if (!Number.isInteger(order) || order < 1) problems.push(`${at}.display_order is not a whole number from 1`);
    else if (orders.has(order)) problems.push(`${at}.display_order repeats ${order}`);
    orders.add(order);

    if (typeof active !== 'boolean') problems.push(`${at}.is_active is not true or false`);
  });
  return problems;
}

// The records to write, one per category, keyed by its identifier (section 12). Refuses a bad seed.
export function seedDocuments(seed = SEED) {
  const problems = seedProblems(seed);
  if (problems.length > 0) throw new Error(`The seed is not usable:\n- ${problems.join('\n- ')}`);
  return seed.notification_categories.map((entry) => ({
    path: `notification_categories/${entry.category_id}`,
    data: { ...entry },
  }));
}

// Writes every seed record in one batch, replacing what is stored under the same key, so a bad seed
// writes nothing. A record that is not in the seed is left alone and named: a category in use cannot be
// deleted (DATABASE_AND_DATA_MODEL.md section 10.2). `db` is an Admin SDK Firestore.
export async function loadSeed(db, seed = SEED) {
  const documents = seedDocuments(seed);
  const batch = db.batch();
  for (const { path, data } of documents) batch.set(db.doc(path), data);
  await batch.commit();

  const written = documents.map(({ data }) => data.category_id);
  const stored = await db.collection('notification_categories').get();
  return { written, others: stored.docs.map((doc) => doc.id).filter((id) => !written.includes(id)).sort() };
}
