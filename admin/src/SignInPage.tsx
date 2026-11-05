// SPIKE (DEC-004 OPEN). SCR-W-01 Admin sign-in. Placeholder visuals: no brand assets, no M2 design.
import { useState } from 'react';
import type { FormEvent } from 'react';
import { MESSAGES } from './messages';
import { signInAdmin } from './signIn';
import type { SignInDeps } from './signIn';

interface Props {
  deps: SignInDeps;
  onSignedIn: () => void;
  // Shown when the page opens, for example after the session was ended because access was lost.
  notice?: string | null;
}

export function SignInPage({ deps, onSignedIn, notice = null }: Props) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<string | null>(notice);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (busy) return;
    setBusy(true);
    setMessage(null);
    const outcome = await signInAdmin(deps, email, password);
    setBusy(false);
    if (outcome === 'signed-in') {
      onSignedIn();
      return;
    }
    // The password is not kept after a failed attempt.
    setPassword('');
    setMessage(outcome === 'unavailable' ? MESSAGES.unavailable : MESSAGES.refused);
  }

  return (
    <main className="page">
      <h1>Admin sign-in</h1>
      <form onSubmit={submit}>
        <label htmlFor="email">Email address</label>
        <input id="email" name="email" type="email" autoComplete="username" required value={email} onChange={(e) => setEmail(e.target.value)} />
        <label htmlFor="password">Password</label>
        <input id="password" name="password" type="password" autoComplete="current-password" required value={password} onChange={(e) => setPassword(e.target.value)} />
        <button type="submit" disabled={busy}>
          {busy ? 'Signing in…' : 'Sign in'}
        </button>
      </form>
      {message && (
        <p role="alert" className="message">
          {message}
        </p>
      )}
    </main>
  );
}
