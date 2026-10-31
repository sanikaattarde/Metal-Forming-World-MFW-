// SPIKE (DEC-003 OPEN). Server operations for the local emulators. The region is not set, because
// DEC-031 is OPEN. App Check is not assumed (OQ-52).
import { getApps, initializeApp } from 'firebase-admin/app';

if (getApps().length === 0) initializeApp();

export { deleteCategory, saveCategory } from './categories.js';
export { getMyAdminRole } from './getMyAdminRole.js';
export { getIssueFile } from './issueFile.js';
export { listIssuesForAdmin, publishIssue, saveIssue, unpublishIssue } from './issues.js';
export { setNewsControl } from './newsControls.js';
export { saveProfile } from './saveProfile.js';
