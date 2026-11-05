// SPIKE. The role check is not built here: it calls OP-14 getMyAdminRole and is MOD12-P2-T01 (B5). Until
// then the panel refuses every account after sign-in. It fails closed, so no account reaches a page that
// the server would refuse anyway.
import type { RoleCheck } from './signIn';

export const roleCheckNotBuilt: RoleCheck = async () => false;
