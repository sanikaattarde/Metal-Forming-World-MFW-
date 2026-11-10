// The sign-in decision for SCR-W-01 (FR-ADMIN-002, FR-ADMIN-003; AC-8.1, AC-8.2).
// A wrong password, an unknown address and an account without the admin role all end in the same
// outcome, so the page cannot tell them apart (SEC-CHK-17). The role check is passed in: the real one,
// which calls OP-14, is MOD12-P2-T01 (B5). The panel's check is a convenience only, and the server checks
// every admin operation again (TD-14, SEC-CHK-06).

export type SignInOutcome = 'signed-in' | 'refused' | 'unavailable';

// The signed-in account, as far as this page needs it.
export interface SignedInUser {
  uid: string;
}

export type RoleCheck = (user: SignedInUser) => Promise<boolean>;

export interface SignInDeps {
  signIn(email: string, password: string): Promise<SignedInUser>;
  signOut(): Promise<void>;
  roleCheck: RoleCheck;
}

// Only a failure to reach the provider gets a message of its own. Every other provider error, including
// too many attempts, is a refusal, so no code reveals whether the address has an account.
const UNAVAILABLE = new Set(['auth/network-request-failed']);

const codeOf = (error: unknown): string =>
  typeof error === 'object' && error !== null && typeof (error as { code?: unknown }).code === 'string'
    ? (error as { code: string }).code
    : '';

export async function signInAdmin(deps: SignInDeps, email: string, password: string): Promise<SignInOutcome> {
  let user: SignedInUser;
  try {
    user = await deps.signIn(email.trim(), password);
  } catch (error) {
    return UNAVAILABLE.has(codeOf(error)) ? 'unavailable' : 'refused';
  }

  // Fail closed: a role check that throws is a refusal, with the same message.
  let isAdmin = false;
  try {
    isAdmin = (await deps.roleCheck(user)) === true;
  } catch {
    isAdmin = false;
  }
  if (isAdmin) return 'signed-in';

  // A refused account does not stay signed in.
  await deps.signOut().catch(() => undefined);
  return 'refused';
}
