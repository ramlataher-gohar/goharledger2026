/*
# Add clears_on to transactions

`clears_on` marks a post-dated cheque or delayed payment as not affecting
wallet balances until the date it actually clears. It's used throughout
the app's balance calculations but was missing from the checked-in
migrations - this adds it so a fresh install matches the live database.
*/

ALTER TABLE transactions ADD COLUMN IF NOT EXISTS clears_on date;
