import { supabase } from './supabase';

async function nextSequentialId(prefix: string): Promise<string> {
  const { data } = await supabase
    .from('transactions')
    .select('transaction_id')
    .like('transaction_id', `${prefix}%`)
    .order('transaction_id', { ascending: false })
    .limit(1);

  let seq = 1;
  if (data && data.length > 0) {
    const match = data[0].transaction_id.match(/-(\d{3})$/);
    if (match) seq = parseInt(match[1]) + 1;
  }
  return `${prefix}-${String(seq).padStart(3, '0')}`;
}

/**
 * Generates the next sequential transaction_id for a prefix and inserts the
 * row in one step. If two saves race and land on the same id, the table's
 * UNIQUE constraint rejects the second insert with a 23505 error, which is
 * retried with a freshly recomputed id (up to maxAttempts) instead of failing.
 */
export async function insertTransactionWithId<T extends Record<string, unknown>>(
  prefix: string,
  buildRow: (transactionId: string) => T,
  maxAttempts = 3
): Promise<{ data: any; error: any; transactionId: string }> {
  let lastError: any = null;
  let txnId = '';
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    txnId = await nextSequentialId(prefix);
    const { data, error } = await supabase.from('transactions').insert(buildRow(txnId)).select().single();
    if (!error) return { data, error: null, transactionId: txnId };
    lastError = error;
    if (error.code !== '23505') break;
  }
  return { data: null, error: lastError, transactionId: txnId };
}
