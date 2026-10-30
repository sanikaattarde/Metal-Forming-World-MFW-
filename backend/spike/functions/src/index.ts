// SPIKE (DEC-003 OPEN). Server operations for the local emulators. The region is not set, because
// DEC-031 is OPEN. App Check is not assumed (OQ-52).
import { getApps, initializeApp } from 'firebase-admin/app';

if (getApps().length === 0) initializeApp();

export { getMyAdminRole } from './getMyAdminRole.js';
export { saveProfile } from './saveProfile.js';
