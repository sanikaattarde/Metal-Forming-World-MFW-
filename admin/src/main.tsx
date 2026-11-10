// Entry point of the admin panel.
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router';
import { App } from './App';
import { MESSAGES } from './messages';
import { createServices } from './services';
import type { Services } from './services';
import './styles.css';

const root = document.getElementById('root');
if (!root) throw new Error('The page has no root element');

const render = (services: Services | null, unavailableNotice?: string) =>
  createRoot(root).render(
    <StrictMode>
      <BrowserRouter>
        <App services={services} unavailableNotice={unavailableNotice} />
      </BrowserRouter>
    </StrictMode>,
  );

// A build with a partial or demo project configuration fails closed with a notice, not a blank page.
createServices(window.location.hostname).then(
  (services) => render(services),
  () => render(null, MESSAGES.badConfiguration),
);
