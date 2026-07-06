/*
# Track who added capital entries and historical profit records

1. Changes
- `capital_entries.created_by` (text, nullable)
- `historical_profit.created_by` (text, nullable)

  Every other table that records an action (transactions, etc.) already tracks
  which logged-in user added it and shows it in the UI as a small "Added by"
  badge. These two tables were missed - they only ever recorded who via
  created_at, never who by.
*/

ALTER TABLE capital_entries ADD COLUMN IF NOT EXISTS created_by text;
ALTER TABLE historical_profit ADD COLUMN IF NOT EXISTS created_by text;
