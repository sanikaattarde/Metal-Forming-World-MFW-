// SPIKE (DEC-003 OPEN, DEC-025 PROPOSED). Profile checks for OP-10 saveProfile, with no database
// access, so they can be tested without the emulators. The mandatory profile is PROVISIONAL (BR-003).
//
// The fields come from configuration (`profile_required_fields`), so OQ-01 can change the set
// without a code change. A field outside the configured set is refused: the contract takes "the
// profile fields in the configured set", and nothing else is collected (NFR-PRIV-001).

// PLACEHOLDER. No document sets a length ("Length limits and formats are proposals",
// DATABASE_AND_DATA_MODEL.md MA-6). It is not a decided value.
export const PLACEHOLDER_MAX_TEXT_LENGTH = 200;

// The sanity range of the working position (GS-Q40, OQ-02). This is not an age gate: there is no
// minimum age (FR-PROF-005). OQ-02 and OQ-07 stay open.
export const AGE_MIN = 1;
export const AGE_MAX = 120;

type Checked = { ok: true; value: string | number } | { ok: false };
type Validator = (value: unknown) => Checked;

const text: Validator = (value) => {
  if (typeof value !== 'string') return { ok: false };
  const trimmed = value.trim();
  if (trimmed.length === 0 || trimmed.length > PLACEHOLDER_MAX_TEXT_LENGTH) return { ok: false };
  return { ok: true, value: trimmed };
};

const wholeNumberAge: Validator = (value) => {
  if (typeof value !== 'number' || !Number.isInteger(value)) return { ok: false };
  if (value < AGE_MIN || value > AGE_MAX) return { ok: false };
  return { ok: true, value };
};

// The five fields of the working position (GS-Q40). The gender options are OPEN (OQ-01), so gender
// is checked as text. The optional candidates and `date_of_birth` are not built (OQ-01, OQ-02).
const VALIDATORS: Record<string, Validator> = {
  full_name: text,
  age_value: wholeNumberAge,
  gender: text,
  job_title: text,
  industry_segment_id: text,
};

export class ConfigError extends Error {}

export interface PublicConfig {
  requiredFields: string[];
  policyVersions: { privacy_policy: string; terms_of_use: string };
}

const isText = (value: unknown): value is string => typeof value === 'string' && value.length > 0;

// Fails closed. A missing or malformed configuration refuses the call (SC-03).
export function parsePublicConfig(data: Record<string, unknown> | undefined): PublicConfig {
  if (!data) throw new ConfigError('public configuration is missing');

  const fields = data.profile_required_fields;
  if (!Array.isArray(fields) || fields.length === 0 || !fields.every(isText)) {
    throw new ConfigError('profile_required_fields is missing or malformed');
  }
  const unknown = fields.filter((name) => !(name in VALIDATORS));
  if (unknown.length > 0) {
    throw new ConfigError(`profile_required_fields names a field with no validator: ${unknown.join(', ')}`);
  }

  const versions = data.policy_versions as Record<string, unknown> | undefined;
  if (!versions || !isText(versions.privacy_policy) || !isText(versions.terms_of_use)) {
    throw new ConfigError('policy_versions is missing or malformed');
  }

  return {
    requiredFields: fields,
    policyVersions: { privacy_policy: versions.privacy_policy, terms_of_use: versions.terms_of_use },
  };
}

export interface ProfileCheck {
  values: Record<string, string | number>;
  invalid: string[]; // field names only, never the values
  missing: string[];
}

export function checkProfile(input: Record<string, unknown>, requiredFields: string[]): ProfileCheck {
  const values: Record<string, string | number> = {};
  const invalid: string[] = [];

  for (const [name, value] of Object.entries(input)) {
    if (!requiredFields.includes(name)) {
      invalid.push(name);
      continue;
    }
    const checked = VALIDATORS[name](value);
    if (checked.ok) values[name] = checked.value;
    else invalid.push(name);
  }

  const missing = requiredFields.filter((name) => !(name in input));
  return { values, invalid: invalid.sort(), missing };
}

export function versionsMatch(accepted: unknown, current: PublicConfig['policyVersions']): boolean {
  if (typeof accepted !== 'object' || accepted === null) return false;
  const given = accepted as Record<string, unknown>;
  return (
    Object.keys(given).length === 2 &&
    given.privacy_policy === current.privacy_policy &&
    given.terms_of_use === current.terms_of_use
  );
}

// A consent record is unique per user, document and version (OP-10), and it lives under the user,
// so the key needs only the document and the version.
export function consentId(documentType: string, documentVersion: string): string {
  return `${documentType}__${encodeURIComponent(documentVersion)}`;
}
