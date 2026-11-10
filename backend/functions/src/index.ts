// The server operations of API_AND_BACKEND_CONTRACT.md (DEC-003, DEC-025 and DEC-026 AGREED).
// The region is not set, because DEC-031 is OPEN. App Check is not assumed (OQ-52).
import { getApps, initializeApp } from 'firebase-admin/app';

if (getApps().length === 0) initializeApp();

export { saveProfile } from './saveProfile.js';
