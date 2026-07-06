// Lightweight client-side password hashing. There's no backend server in this
// app to do proper bcrypt-style hashing, so this is a lightweight improvement
// over a literal password in the source code, not bank-grade security - fine
// for a 2-person internal tool, not something to reuse for a public-facing app.
export async function hashPassword(username: string, password: string): Promise<string> {
  const data = new TextEncoder().encode(`${username.toLowerCase()}:${password}`);
  const digest = await crypto.subtle.digest('SHA-256', data);
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}
