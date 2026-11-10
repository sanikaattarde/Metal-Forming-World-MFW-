// Renders the panel inside a router held in memory, and signs in through the page, for the tests
// that use stand-ins.
import { fireEvent, render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router';
import { App } from '../src/App';
import type { Services } from '../src/services';

export function renderApp(services: Services | null, path = '/', unavailableNotice?: string) {
  return render(
    <MemoryRouter initialEntries={[path]}>
      <App services={services} unavailableNotice={unavailableNotice} />
    </MemoryRouter>,
  );
}

export function fillSignIn(email = 'admin@example.test', password = 'a-password') {
  fireEvent.change(screen.getByLabelText('Email address'), { target: { value: email } });
  fireEvent.change(screen.getByLabelText('Password'), { target: { value: password } });
  fireEvent.click(screen.getByRole('button', { name: 'Sign in' }));
}

export async function signedInApp(services: Services, path = '/') {
  const result = renderApp(services, path);
  fillSignIn();
  await screen.findByRole('heading', { name: 'Admin panel' });
  return result;
}
