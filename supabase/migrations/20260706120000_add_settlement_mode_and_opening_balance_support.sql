/*
# Add settlement_mode to transactions

1. Changes
- `transactions.settlement_mode` (text, nullable) - for an Advance-mode sale, this
  stores which real payment channel (mpesa/cash/paybill) the advance was originally
  paid in. Previously the app overwrote `primary_mode` itself with this value, which
  made it impossible to tell an advance sale apart from a plain mpesa/cash/paybill
  sale - breaking filtering, editing, voiding, and causing the settled amount to be
  double-counted in cash balances (once at deposit, again at spend). Going forward
  `primary_mode` stays 'advance' and this column carries the settlement channel.

2. Backfill
- Existing advance-mode sales are identifiable by their note text
  ("Advance payment via <mode>"), and their `primary_mode` column currently
  already holds the settlement channel (that was the bug). So for those rows we
  copy `primary_mode` into the new `settlement_mode` column, then correct
  `primary_mode` to 'advance' - this retroactively fixes historical double
  counting too, not just new entries going forward.
*/

ALTER TABLE transactions ADD COLUMN IF NOT EXISTS settlement_mode text;

UPDATE transactions
SET settlement_mode = primary_mode,
    primary_mode = 'advance'
WHERE type = 'sale'
  AND primary_mode <> 'advance'
  AND notes LIKE 'Advance payment via%';
