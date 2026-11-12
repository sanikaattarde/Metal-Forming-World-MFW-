// The frame around every admin screen: the menu and sign-out. Placeholder visuals.
import { NavLink, Outlet } from 'react-router';

interface Props {
  onSignOut: () => void;
  // The Admins entry, when switched on (MOD12-P3-T02).
  adminManagement?: boolean;
}

export function AdminLayout({ onSignOut, adminManagement = false }: Props) {
  return (
    <div className="admin">
      <header className="admin-header">
        <h1>Admin panel</h1>
        <nav aria-label="Admin sections">
          <NavLink to="/issues">Issues</NavLink>
          <NavLink to="/categories">Categories</NavLink>
          <NavLink to="/news">News</NavLink>
          <NavLink to="/notifications">Notifications</NavLink>
          <NavLink to="/readers">Readers</NavLink>
          {adminManagement && <NavLink to="/admins">Admins</NavLink>}
        </nav>
        <button type="button" onClick={onSignOut}>
          Sign out
        </button>
      </header>
      <main className="admin-main">
        <Outlet />
      </main>
    </div>
  );
}
