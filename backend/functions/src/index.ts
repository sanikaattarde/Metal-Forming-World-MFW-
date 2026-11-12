// The server operations of API_AND_BACKEND_CONTRACT.md (DEC-003, DEC-025 and DEC-026 AGREED).
// The region is not set, because DEC-031 is OPEN. App Check is not assumed (OQ-52).
import { getApps, initializeApp } from 'firebase-admin/app';

if (getApps().length === 0) initializeApp();

export { requestAccountDeletion } from './accountDeletion.js';
export { addAdmin, listAdminChanges, listAdmins, removeAdmin } from './adminManagement.js';
export { deleteCategory, saveCategory } from './categories.js';
export { deleteIssue } from './issueDeletion.js';
export { getIssueFile } from './issueFile.js';
export { getMyAdminRole } from './getMyAdminRole.js';
export { listIssuesForAdmin, publishIssue, saveIssue, unpublishIssue } from './issues.js';
export { setNewsControl } from './newsControls.js';
export { listNotificationSends, retryNotification, sendNotification } from './notifications.js';
export { listWordPressPosts } from './wordpress.js';
export { exportRegisteredUsers, listRegisteredUsers } from './registeredUsers.js';
export { saveProfile } from './saveProfile.js';
export { onUploadFinalized } from './uploadFinalized.js';
export { listUploadJobs, requestUpload } from './uploads.js';
