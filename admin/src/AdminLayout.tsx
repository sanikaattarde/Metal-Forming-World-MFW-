// The frame around every admin screen: the menu and sign-out. Placeholder visuals.
import { NavLink, Outlet } from 'react-router';

interface Props {
  onSignOut: () => void;
}

export function AdminLayout({ onSignOut }: Props) {
  return (
    <div className="admin">
      <header className="admin-header">
        <h1>Admin panel</h1>
        <nav aria-label="Admin sections">
          <NavLink to="/issues">Issues</NavLink>
          <NavLink to="/categories">Categories</NavLink>
          <NavLink to="/news">News</NavLink>
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
