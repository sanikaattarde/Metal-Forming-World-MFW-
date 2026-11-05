// SPIKE (DEC-004 OPEN). Entry point of the admin panel skeleton.
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router';
import { App } from './App';
import { createServices } from './services';
import './styles.css';

const root = document.getElementById('root');
if (!root) throw new Error('The page has no root element');

createServices(window.location.hostname).then((services) => {
  createRoot(root).render(
    <StrictMode>
      <BrowserRouter>
        <App services={services} />
      </BrowserRouter>
    </StrictMode>,
  );
});
