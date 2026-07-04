/*
  # Track when a transaction was edited

  Adds `edited_at`, set whenever a transaction is updated after its original
  creation (never set on insert). The app uses this to show a small
  "Edited" indicator wherever the transaction appears, so it's clear the
  original entry was changed later.
*/
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS edited_at TIMESTAMPTZ;
