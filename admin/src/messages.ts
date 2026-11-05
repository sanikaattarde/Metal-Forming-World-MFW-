// SPIKE. PLACEHOLDER wording: there is no M2 design, and the sign-in measures wait for OQ-20.
// One message covers a wrong password, an unknown address, an account without the admin role and an admin
// whose email is not verified (OQ-20).
export const MESSAGES = {
  refused: 'Sign-in failed. Check the email address and the password, and that this account has admin access.',
  unavailable: 'Sign-in could not be completed. Check the connection and try again.',
  notConfigured: 'This build of the admin panel runs only against the local emulators.',
  accessEnded: 'Your admin access has ended, so you have been signed out.',
} as const;
