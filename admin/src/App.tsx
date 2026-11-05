// SPIKE (DEC-004 OPEN). The admin panel: the sign-in page, and the admin screens after sign-in. The role check
// calls OP-14 (MOD12-P2-T01). The session ends when access is lost: when any server operation refuses the
// account as no longer an admin, and when the panel comes back into focus and OP-14 says so.
import { useCallback, useEffect, useMemo, useState } from 'react';
import { Navigate, Route, Routes } from 'react-router';
import { AdminLayout } from './AdminLayout';
import { adminApi } from './adminApi';
import { CategoriesPage } from './CategoriesPage';
import { IssueEditorRoute } from './IssueEditor';
import { IssuesPage } from './IssuesPage';
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
      <Routes>
        <Route element={<AdminLayout onSignOut={() => endSession(null)} />}>
          <Route path="/issues" element={<IssuesPage api={api} />} />
          <Route path="/issues/new" element={<IssueEditorRoute api={api} read={services.read} />} />
          <Route path="/issues/:issueId" element={<IssueEditorRoute api={api} read={services.read} />} />
          <Route path="/categories" element={<CategoriesPage api={api} read={services.read} />} />
          <Route path="*" element={<Navigate to="/issues" replace />} />
        </Route>
      </Routes>
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
