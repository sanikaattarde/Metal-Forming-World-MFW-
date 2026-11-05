// SPIKE (DEC-004 OPEN). The admin panel: the sign-in page, and the admin area after sign-in. The role check
// calls OP-14 (MOD12-P2-T01). The session ends when access is lost: when any server operation refuses the
// account as no longer an admin, and when the panel comes back into focus and OP-14 says so.
import { useCallback, useEffect, useMemo, useState } from 'react';
import { adminApi } from './adminApi';
import { MESSAGES } from './messages';
import type { Services } from './services';
import { SignInPage } from './SignInPage';

interface Props {
  // null: the page is not served from a local address, so no services exist.
  services: Services | null;
}

export function App({ services }: Props) {
  const [signedIn, setSignedIn] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);

  const endSession = useCallback(
    (reason: string | null) => {
      if (!services) return;
      void services.signOut().finally(() => {
        setNotice(reason);
        setSignedIn(false);
      });
    },
    [services],
  );

  const api = useMemo(() => (services ? adminApi(services.call, () => endSession(MESSAGES.accessEnded)) : null), [services, endSession]);

  // Coming back to the panel checks the role again, so an admin removed while away is signed out.
  useEffect(() => {
    if (!signedIn || !services) return;
    const recheck = () => {
      services.roleCheck({ uid: '' }).then(
        (stillAdmin) => {
          if (!stillAdmin) endSession(MESSAGES.accessEnded);
        },
        () => undefined,
      );
    };
    window.addEventListener('focus', recheck);
    return () => window.removeEventListener('focus', recheck);
  }, [signedIn, services, endSession]);

  if (!services || !api) {
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
        <p>Signed in. The admin screens come in the next step.</p>
        <button type="button" onClick={() => endSession(null)}>
          Sign out
        </button>
      </main>
    );
  }

  return (
    <SignInPage
      key={notice ?? 'sign-in'}
      deps={services}
      notice={notice}
      onSignedIn={() => {
        setNotice(null);
        setSignedIn(true);
      }}
    />
  );
}
