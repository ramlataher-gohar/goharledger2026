import { supabase } from './supabase';

// These always re-read the current value from the database right before
// writing, instead of trusting a possibly-stale value already held in
// component state. This avoids lost updates when two balance changes for
// the same record happen in close succession (e.g. two invoices added
// back-to-back before the screen has refreshed).

// Suppliers/customers balances are allowed to go negative on purpose: a negative
// supplier balance means the supplier owes the shop (e.g. a supplier-mode sale
// recorded before any invoice existed to offset it against), and a negative
// customer credit/advance balance means the shop owes the customer. Flooring at
// zero used to silently discard that credit instead of letting it carry forward
// and net out against the next invoice/sale - callers that display these values
// should style a negative balance as a credit, not just a bare negative number.
export async function adjustSupplierBalance(supplierId: string, delta: number): Promise<void> {
  const { data } = await supabase.from('suppliers').select('balance').eq('id', supplierId).single();
  const next = (data?.balance || 0) + delta;
  await supabase.from('suppliers').update({ balance: next }).eq('id', supplierId);
}

export async function adjustCustomerCredit(customerId: string, delta: number): Promise<void> {
  const { data } = await supabase.from('customers').select('credit_balance').eq('id', customerId).single();
  const next = (data?.credit_balance || 0) + delta;
  await supabase.from('customers').update({ credit_balance: next }).eq('id', customerId);
}

export async function adjustCustomerAdvance(customerId: string, delta: number): Promise<void> {
  const { data } = await supabase.from('customers').select('advance_balance').eq('id', customerId).single();
  const next = (data?.advance_balance || 0) + delta;
  await supabase.from('customers').update({ advance_balance: next }).eq('id', customerId);
}

// positive paymentDelta = a payment was made (remaining down, paid up)
// negative paymentDelta = reversing a payment (remaining up, paid down)
export async function adjustLoanBalance(loanId: string, paymentDelta: number): Promise<void> {
  const { data } = await supabase.from('loan_trackers').select('remaining_balance, amount_paid').eq('id', loanId).single();
  const newBal = Math.max(0, (data?.remaining_balance || 0) - paymentDelta);
  const newPaid = Math.max(0, (data?.amount_paid || 0) + paymentDelta);
  await supabase.from('loan_trackers').update({
    remaining_balance: newBal,
    amount_paid: newPaid,
    status: newBal <= 0 ? 'settled' : 'active',
  }).eq('id', loanId);
}
