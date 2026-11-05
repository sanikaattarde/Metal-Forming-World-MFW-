// SPIKE (DEC-004 OPEN). The admin panel skeleton: the sign-in page, and a placeholder after sign-in. No admin
// screen is built here (B5). With the role check not built, the built panel refuses every account, so the
// placeholder is reached only in tests that pass in a role check of their own.
import { useState } from 'react';
import { MESSAGES } from './messages';
import { SignInPage } from './SignInPage';
import type { SignInDeps } from './signIn';

interface Props {
  // null: the page is not served from a local address, so no services exist.
  services: SignInDeps | null;
}

export function App({ services }: Props) {
  const [signedIn, setSignedIn] = useState(false);

  if (!services) {
    return (
      <main className="page">
        <h1>Admin panel</h1>
        <p role="alert" className="message">
          {MESSAGES.notConfigured}
        </p>
      </main>
    );
  }

  if (signedIn) {
    return (
      <main className="page">
        <h1>Admin panel</h1>
        <p>Signed in. No admin screen is built in this spike.</p>
        <button type="button" onClick={() => services.signOut().finally(() => setSignedIn(false))}>
          Sign out
        </button>
      </main>
    );
  }

  return <SignInPage deps={services} onSignedIn={() => setSignedIn(true)} />;
}
