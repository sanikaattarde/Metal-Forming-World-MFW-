// Unit tests of the seed definitions (MOD13-P1-T10): the seed
// file itself, the checks that refuse a bad one, and the loader's command. No database.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { SEED, seedDocuments, seedProblems } from '../seed/seed.mjs';

const LOADER = new URL('../seed/load.mjs', import.meta.url).pathname;
const runLoader = (args, env = process.env) =>
  spawnSync(process.execPath, [LOADER, ...args], { encoding: 'utf8', env, timeout: 20_000 });

// ---- The seed file ----

test('U4 the seed file passes its own checks', () => {
  assert.deepEqual(seedProblems(SEED), []);
});

test('U4 the seed holds the three categories of the working position, with stable identifiers (GS-Q47)', () => {
  const list = SEED.notification_categories;
  // A changed identifier would orphan stored preferences and subscribed topics, so they are pinned.
  assert.deepEqual(list.map((entry) => entry.category_id), ['notif-new-issues', 'notif-expo-specials', 'notif-major-news']);
  assert.deepEqual(list.map((entry) => entry.name.toLowerCase()), ['new issues', 'expo specials', 'major news']);
  assert.deepEqual(list.map((entry) => entry.display_order), [1, 2, 3]);
  assert.deepEqual(list.map((entry) => entry.is_active), [true, true, true]);
});

test('U4 no segment list is seeded, because OQ-13 is open', () => {
  assert.deepEqual(Object.keys(SEED).sort(), ['about', 'notification_categories']);
});

test('U4 each record is keyed by its identifier and holds exactly the seed entry', () => {
  const documents = seedDocuments();
  assert.deepEqual(documents.map(({ path }) => path), SEED.notification_categories.map((entry) => `notification_categories/${entry.category_id}`));
  documents.forEach(({ data }, index) => assert.deepEqual(data, SEED.notification_categories[index]));
});

// ---- A bad seed is refused ----

const broken = (change) => {
  const seed = structuredClone(SEED);
  change(seed.notification_categories, seed);
  return seed;
};

const BROKEN = {
  'a repeated identifier': [(list) => { list[1].category_id = list[0].category_id; }, 'category_id repeats'],
  'a name repeated in another case': [(list) => { list[1].name = list[0].name.toUpperCase(); }, 'name repeats'],
  'a repeated order': [(list) => { list[1].display_order = list[0].display_order; }, 'display_order repeats'],
  'a missing field': [(list) => { delete list[0].is_active; }, 'must have exactly'],
  'an extra field': [(list) => { list[0].colour = 'red'; }, 'must have exactly'],
  'an identifier with a slash': [(list) => { list[0].category_id = 'notif/new'; }, 'category_id'],
  'an identifier with capitals': [(list) => { list[0].category_id = 'Notif-New'; }, 'category_id'],
  'an identifier with a space': [(list) => { list[0].category_id = 'notif new'; }, 'category_id'],
  'an identifier of two dots': [(list) => { list[0].category_id = '..'; }, 'category_id'],
  'an empty identifier': [(list) => { list[0].category_id = ''; }, 'category_id'],
  'an identifier that is a number': [(list) => { list[0].category_id = 7; }, 'category_id'],
  'an empty name': [(list) => { list[0].name = ''; }, 'name is empty'],
  'a blank name': [(list) => { list[0].name = '   '; }, 'name is empty'],
  'a name with a space at an end': [(list) => { list[0].name = ' New issues'; }, 'name has spaces'],
  'a name that is not text': [(list) => { list[0].name = 1; }, 'name is empty'],
  'a fractional order': [(list) => { list[0].display_order = 1.5; }, 'display_order'],
  'an order as text': [(list) => { list[0].display_order = '1'; }, 'display_order'],
  'an order of zero': [(list) => { list[0].display_order = 0; }, 'display_order'],
  'is_active as text': [(list) => { list[0].is_active = 'true'; }, 'is_active'],
  'an entry that is not an object': [(list) => { list[0] = 'notif-new-issues'; }, 'is not an object'],
  'an empty list': [(list, seed) => { seed.notification_categories = []; }, 'not a list with entries'],
  'a list that is an object': [(list, seed) => { seed.notification_categories = { a: list[0] }; }, 'not a list with entries'],
  'a segment list added before OQ-13': [(list, seed) => { seed.segments = []; }, 'unknown top-level keys: segments'],
  'about that is not text': [(list, seed) => { seed.about = 1; }, 'about is not text'],
};

for (const [name, [change, expected]] of Object.entries(BROKEN)) {
  test(`U4 a bad seed is refused: ${name}`, () => {
    const seed = broken(change);
    const problems = seedProblems(seed);
    assert.ok(problems.some((problem) => problem.includes(expected)), problems.join(' | '));
    assert.throws(() => seedDocuments(seed), /The seed is not usable/);
  });
}

for (const value of [null, [], 'seed', 7]) {
  test(`U4 a seed that is not an object is refused: ${JSON.stringify(value)}`, () => {
    assert.deepEqual(seedProblems(value), ['the seed is not an object']);
  });
}

test('U4 every problem is named in one run', () => {
  const seed = broken((list) => {
    list[0].category_id = 'Bad';
    list[1].display_order = 0;
    list[2].is_active = 'yes';
  });
  assert.equal(seedProblems(seed).length, 3);
});

// ---- The command ----

test('U4 the command checks the seed without an emulator', () => {
  const env = { ...process.env };
  delete env.FIRESTORE_EMULATOR_HOST;
  const run = runLoader(['--check'], env);
  assert.equal(run.status, 0, run.stderr);
  assert.match(run.stdout, /notif-new-issues, notif-expo-specials, notif-major-news/);
});

test('U4 the command refuses an option it does not know', () => {
  const run = runLoader(['--project=real']);
  assert.equal(run.status, 2);
  assert.match(run.stderr, /Usage/);
});
