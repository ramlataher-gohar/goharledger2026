/*
# Require a real login for all database access

1. Background
- Every table's policies were `TO anon, authenticated USING (true)`, which
  means the public anon key alone (visible in the deployed JS bundle) granted
  full read/write/delete access to the entire database with no login at all.
- The app has moved from a forgeable localStorage session to real Supabase
  Auth (see AuthContext.tsx). This migration is the other half of that fix:
  it removes the `anon` grant everywhere so a request only succeeds once
  someone has actually signed in.

2. The one exception: `users` SELECT
- Logging in for the very first time under the new scheme still needs to read
  the `users` table (by username) as `anon`, before an Auth session exists,
  to check the old password hash and silently create the matching real Auth
  account. `select_users` is left open to `anon` for that bootstrap window.
- Once both partners have logged in at least once under the new system, a
  follow-up migration should drop the legacy fallback code and lock this
  last policy down to `authenticated` too.

3. Everything else
- INSERT/UPDATE/DELETE on `users`, and all four verbs on every other table,
  now require `authenticated`.
*/

-- users: keep SELECT open to anon (needed for the login bootstrap), lock the rest down
DROP POLICY IF EXISTS "insert_users" ON users;
CREATE POLICY "insert_users" ON users FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "update_users" ON users;
CREATE POLICY "update_users" ON users FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "delete_users" ON users;
CREATE POLICY "delete_users" ON users FOR DELETE TO authenticated USING (true);

-- business_profile
DROP POLICY IF EXISTS "select_business_profile" ON business_profile;
CREATE POLICY "select_business_profile" ON business_profile FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "insert_business_profile" ON business_profile;
CREATE POLICY "insert_business_profile" ON business_profile FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "update_business_profile" ON business_profile;
CREATE POLICY "update_business_profile" ON business_profile FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "delete_business_profile" ON business_profile;
CREATE POLICY "delete_business_profile" ON business_profile FOR DELETE TO authenticated USING (true);

-- customers
DROP POLICY IF EXISTS "select_customers" ON customers;
CREATE POLICY "select_customers" ON customers FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "insert_customers" ON customers;
CREATE POLICY "insert_customers" ON customers FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "update_customers" ON customers;
CREATE POLICY "update_customers" ON customers FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "delete_customers" ON customers;
CREATE POLICY "delete_customers" ON customers FOR DELETE TO authenticated USING (true);

-- suppliers
DROP POLICY IF EXISTS "select_suppliers" ON suppliers;
CREATE POLICY "select_suppliers" ON suppliers FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "insert_suppliers" ON suppliers;
CREATE POLICY "insert_suppliers" ON suppliers FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "update_suppliers" ON suppliers;
CREATE POLICY "update_suppliers" ON suppliers FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "delete_suppliers" ON suppliers;
CREATE POLICY "delete_suppliers" ON suppliers FOR DELETE TO authenticated USING (true);

-- loan_trackers
DROP POLICY IF EXISTS "select_loan_trackers" ON loan_trackers;
CREATE POLICY "select_loan_trackers" ON loan_trackers FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "insert_loan_trackers" ON loan_trackers;
CREATE POLICY "insert_loan_trackers" ON loan_trackers FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "update_loan_trackers" ON loan_trackers;
CREATE POLICY "update_loan_trackers" ON loan_trackers FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "delete_loan_trackers" ON loan_trackers;
CREATE POLICY "delete_loan_trackers" ON loan_trackers FOR DELETE TO authenticated USING (true);

-- transactions
DROP POLICY IF EXISTS "select_transactions" ON transactions;
CREATE POLICY "select_transactions" ON transactions FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "insert_transactions" ON transactions;
CREATE POLICY "insert_transactions" ON transactions FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "update_transactions" ON transactions;
CREATE POLICY "update_transactions" ON transactions FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "delete_transactions" ON transactions;
CREATE POLICY "delete_transactions" ON transactions FOR DELETE TO authenticated USING (true);

-- transaction_splits
DROP POLICY IF EXISTS "select_transaction_splits" ON transaction_splits;
CREATE POLICY "select_transaction_splits" ON transaction_splits FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "insert_transaction_splits" ON transaction_splits;
CREATE POLICY "insert_transaction_splits" ON transaction_splits FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "update_transaction_splits" ON transaction_splits;
CREATE POLICY "update_transaction_splits" ON transaction_splits FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "delete_transaction_splits" ON transaction_splits;
CREATE POLICY "delete_transaction_splits" ON transaction_splits FOR DELETE TO authenticated USING (true);

-- share_rules
DROP POLICY IF EXISTS "select_share_rules" ON share_rules;
CREATE POLICY "select_share_rules" ON share_rules FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "insert_share_rules" ON share_rules;
CREATE POLICY "insert_share_rules" ON share_rules FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "update_share_rules" ON share_rules;
CREATE POLICY "update_share_rules" ON share_rules FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "delete_share_rules" ON share_rules;
CREATE POLICY "delete_share_rules" ON share_rules FOR DELETE TO authenticated USING (true);

-- capital_entries
DROP POLICY IF EXISTS "select_capital_entries" ON capital_entries;
CREATE POLICY "select_capital_entries" ON capital_entries FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "insert_capital_entries" ON capital_entries;
CREATE POLICY "insert_capital_entries" ON capital_entries FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "update_capital_entries" ON capital_entries;
CREATE POLICY "update_capital_entries" ON capital_entries FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "delete_capital_entries" ON capital_entries;
CREATE POLICY "delete_capital_entries" ON capital_entries FOR DELETE TO authenticated USING (true);

-- historical_profit
DROP POLICY IF EXISTS "select_historical_profit" ON historical_profit;
CREATE POLICY "select_historical_profit" ON historical_profit FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "insert_historical_profit" ON historical_profit;
CREATE POLICY "insert_historical_profit" ON historical_profit FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "update_historical_profit" ON historical_profit;
CREATE POLICY "update_historical_profit" ON historical_profit FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "delete_historical_profit" ON historical_profit;
CREATE POLICY "delete_historical_profit" ON historical_profit FOR DELETE TO authenticated USING (true);

-- expense_categories
DROP POLICY IF EXISTS "select_expense_categories" ON expense_categories;
CREATE POLICY "select_expense_categories" ON expense_categories FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "insert_expense_categories" ON expense_categories;
CREATE POLICY "insert_expense_categories" ON expense_categories FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "update_expense_categories" ON expense_categories;
CREATE POLICY "update_expense_categories" ON expense_categories FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "delete_expense_categories" ON expense_categories;
CREATE POLICY "delete_expense_categories" ON expense_categories FOR DELETE TO authenticated USING (true);

-- loan_categories
DROP POLICY IF EXISTS "select_loan_categories" ON loan_categories;
CREATE POLICY "select_loan_categories" ON loan_categories FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "insert_loan_categories" ON loan_categories;
CREATE POLICY "insert_loan_categories" ON loan_categories FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "update_loan_categories" ON loan_categories;
CREATE POLICY "update_loan_categories" ON loan_categories FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "delete_loan_categories" ON loan_categories;
CREATE POLICY "delete_loan_categories" ON loan_categories FOR DELETE TO authenticated USING (true);

-- reminders
DROP POLICY IF EXISTS "select_reminders" ON reminders;
CREATE POLICY "select_reminders" ON reminders FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "insert_reminders" ON reminders;
CREATE POLICY "insert_reminders" ON reminders FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "update_reminders" ON reminders;
CREATE POLICY "update_reminders" ON reminders FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "delete_reminders" ON reminders;
CREATE POLICY "delete_reminders" ON reminders FOR DELETE TO authenticated USING (true);

-- loan_payments
DROP POLICY IF EXISTS "select_loan_payments" ON loan_payments;
CREATE POLICY "select_loan_payments" ON loan_payments FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "insert_loan_payments" ON loan_payments;
CREATE POLICY "insert_loan_payments" ON loan_payments FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "update_loan_payments" ON loan_payments;
CREATE POLICY "update_loan_payments" ON loan_payments FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "delete_loan_payments" ON loan_payments;
CREATE POLICY "delete_loan_payments" ON loan_payments FOR DELETE TO authenticated USING (true);
