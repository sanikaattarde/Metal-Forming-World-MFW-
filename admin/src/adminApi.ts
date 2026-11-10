// The one way the panel calls a server operation (B5). The panel's checks are a
// convenience only: the server checks every admin operation again (TD-14, SEC-CHK-06).
//
// MOD12-P2-T01 step 4: the session ends when the role is removed. The server reads the role on every call
// (INV-08), so a refusal that means "no longer an admin" signs the panel out at once.
import type { RoleCheck } from './signIn';

export type CallFn = (name: string, data: unknown) => Promise<unknown>;

// Thrown to the screen after the session has been ended, so it stops what it was doing.
export class AccessLost extends Error {
  constructor() {
    super('The admin session has ended.');
    this.name = 'AccessLost';
  }
}

// The refusals that mean the caller can no longer act as an admin.
const ENDING_REASONS = new Set(['ACCOUNT_CLOSED', 'EMAIL_NOT_VERIFIED']);

export function endsAccess(error: unknown): boolean {
  const { code, details } = (error ?? {}) as { code?: unknown; details?: { reason?: unknown } };
  if (code === 'functions/permission-denied' || code === 'functions/unauthenticated') return true;
  return code === 'functions/failed-precondition' && typeof details?.reason === 'string' && ENDING_REASONS.has(details.reason);
}

export function adminApi(call: CallFn, onAccessLost: () => void): CallFn {
  return async (name, data) => {
    try {
      return await call(name, data);
    } catch (error) {
      if (endsAccess(error)) {
        onAccessLost();
        throw new AccessLost();
      }
      throw error;
    }
  };
}

// OP-14 getMyAdminRole. An account is an admin to the panel only if the role exists, is active and the
// email is verified (OQ-20). OP-14 is never an authorisation in itself (GS-D20).
export const roleCheckThrough =
  (call: CallFn): RoleCheck =>
  async () => {
    const reply = (await call('getMyAdminRole', {})) as { is_admin?: unknown; is_active?: unknown; email_verified?: unknown } | null;
    return reply?.is_admin === true && reply.is_active === true && reply.email_verified === true;
  };
