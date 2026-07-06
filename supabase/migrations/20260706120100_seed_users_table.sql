/*
# Seed the users table with the two existing accounts

1. Notes
- The `users` table has existed since the very first migration but was never
  actually used - login was hardcoded in the app's AuthContext.tsx with a single
  shared password ("gohar") for both accounts. This seeds real rows so the app can
  move to checking real stored credentials instead, letting each partner change
  their own username/password from Settings.
- password_hash is SHA-256 of "<username>:gohar" (lowercase username), matching
  the same starting password as before. This is a lightweight hash appropriate for
  a client-only app with no backend to do proper server-side hashing - not intended
  to be bank-grade security, just a real improvement over a literal password in
  the source code.
*/

INSERT INTO users (username, password_hash, role, full_name, is_active)
VALUES
  ('taher', '9b7e94eed4b42296a9057e49f6bfa4eed80db9f70e4e438591ef6d1f1d4d30a9', 'admin', 'Taher', true),
  ('abdulqadir', '26f8c14ddb53966a2cf5759051fe5edb257610701ef647df083ba6321383d8b6', 'admin', 'Abdulqadir', true)
ON CONFLICT (username) DO NOTHING;
