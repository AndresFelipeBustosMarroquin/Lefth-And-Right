# Auth server

## Local setup

1. Create a local `.env` from `.env.example` and fill in the PostgreSQL settings,
   a private JWT secret, and a Gmail App Password. Do not commit `.env`.
2. Run `migrations/001_email_verification.sql` and
   `migrations/002_password_reset.sql` against the same database used by this
   server before starting it.
3. Install dependencies with `npm install` and start with `node index.js`.

The server listens on port 4000 by default and on all network interfaces. Keep
the machine firewall limited to trusted development devices.
Browser clients served from `localhost` or `127.0.0.1` are allowed for local
development. For other browser origins, set `CORS_ORIGINS` in `.env` to a
comma-separated list of exact origins, including the scheme and port when
applicable (for example, `https://app.example.com`). Restart the server after
changing this setting. Native Flutter clients do not send a browser origin.

## Gmail

Enable two-step verification on the Google account and create an App Password
for this server. Store that App Password as `GMAIL_APP_PASSWORD`; never use the
account's regular password or expose the App Password in Flutter.

## Authentication endpoints

- `POST /register`: create a pending account and send a six-digit code.
- `POST /verify-email`: verify `{ "correo": "...", "codigo": "123456" }`.
- `POST /resend-verification`: send another code for an unverified account.
- `POST /forgot-password`: request a password-recovery code with
  `{ "correo": "..." }`.
- `POST /verify-reset-code`: validate a recovery code with
  `{ "correo": "...", "codigo": "123456" }`.
- `POST /reset-password`: set a new password with
  `{ "correo": "...", "codigo": "123456", "nueva_contrasena": "..." }`.
- `POST /login`: authenticate a registered, verified account.

Verification and password-recovery codes expire after 10 minutes, are limited
to five attempts, and can only be resent after 60 seconds. Password recovery
only sends codes for verified accounts. Run both database migrations before
using these routes.
