// Parses a raw copy-paste from an external sales export (e.g. a POS system's
// sales table) into individual sale records. Built around the export format
// seen in practice: a "Sale Id / Date / Items / Sold By / Sold To / Subtotal /
// Total / Profit / Cost Of Goods Sold / Payment Type" row (tab-separated,
// often preceded by "+"/"Edit ####"/"Clone" action-button text from the
// source page), followed by a Comments line.

const DATE_RE = /(\d{2})-(\d{2})-(\d{4})-(\d{1,2}):(\d{2})\s*(am|pm)/i;

export interface ParsedSmartRow {
  posId: string | null;
  date: string; // ISO yyyy-mm-dd
  soldTo: string;
  total: number;
  costOfGoods: number;
  paymentTypeStr: string;
  comments: string;
}

export function parseKsh(s: string | undefined | null): number {
  if (!s) return 0;
  const n = parseFloat(String(s).replace(/[^\d.-]/g, ''));
  return isNaN(n) ? 0 : n;
}

function isControlLine(line: string): boolean {
  const t = line.trim();
  if (t === '') return true;
  if (/^\+/.test(t)) return true;
  if (/^Edit\s+\d+$/i.test(t)) return true;
  if (/^Clone$/i.test(t)) return true;
  return false;
}

export function parseSmartEntryText(raw: string): ParsedSmartRow[] {
  const lines = raw.split('\n');
  const dataLineIdx: number[] = [];
  lines.forEach((l, idx) => { if (DATE_RE.test(l)) dataLineIdx.push(idx); });

  const rows: ParsedSmartRow[] = [];
  dataLineIdx.forEach((idx, k) => {
    const line = lines[idx];
    const cols = line.split('\t');
    const dateColIdx = cols.findIndex((c) => DATE_RE.test(c));
    const m = cols[dateColIdx].match(DATE_RE);
    if (!m) return;

    const soldTo = (cols[dateColIdx + 3] || '').trim();
    const total = parseKsh(cols[dateColIdx + 5]);
    const costOfGoods = parseKsh(cols[dateColIdx + 7]);
    const paymentTypeStr = (cols[dateColIdx + 8] || '').trim();

    // The source's own Sale ID sits in a preceding "Edit ####" line - carried
    // along purely so a re-paste of the same rows can be recognised and
    // skipped instead of silently creating a duplicate sale.
    let posId: string | null = null;
    for (let i = idx - 1; i >= 0 && i >= idx - 3; i--) {
      const em = lines[i].match(/Edit\s+(\d+)/i);
      if (em) { posId = em[1]; break; }
    }

    const nextIdx = dataLineIdx[k + 1] !== undefined ? dataLineIdx[k + 1] : lines.length;
    const commentLines: string[] = [];
    for (let i = idx + 1; i < nextIdx; i++) {
      if (!isControlLine(lines[i])) commentLines.push(lines[i].trim());
    }

    rows.push({
      posId,
      date: `${m[3]}-${m[2]}-${m[1]}`,
      soldTo,
      total,
      costOfGoods,
      paymentTypeStr,
      comments: commentLines.join(' ').trim(),
    });
  });
  return rows;
}

export type PaymentMode = 'cash' | 'mpesa' | 'paybill';

export interface PaymentPart {
  label: string;
  amount: number;
  mode: PaymentMode | null;
}

export function parsePayments(str: string): PaymentPart[] {
  if (!str) return [];
  const parts: PaymentPart[] = [];
  for (const part of str.split(',')) {
    const m = part.match(/([A-Za-z_ ]+):\s*Ksh?\s*([\d,]+\.?\d*)/i);
    if (!m) continue;
    const label = m[1].trim();
    const lower = label.toLowerCase();
    let mode: PaymentMode | null = null;
    if (lower.includes('mpesa')) mode = 'mpesa';
    else if (lower.includes('cash')) mode = 'cash';
    else if (lower.includes('im_bank') || lower.includes('bank') || lower.includes('paybill')) mode = 'paybill';
    parts.push({ label, amount: parseKsh(m[2]), mode });
  }
  return parts;
}

export interface CommissionDetection {
  amount: number;
  // true = comment explicitly says "LESS ### CMSN", safe to auto-apply.
  // false = comment says "LESS ###" without confirming it's commission -
  // flagged for a human to decide instead of guessing.
  confident: boolean;
}

export function detectCommission(comments: string): CommissionDetection | null {
  const strong = comments.match(/less\s+([\d,]+(?:\.\d+)?)\s*cmsn/i);
  if (strong) return { amount: parseKsh(strong[1]), confident: true };
  const weak = comments.match(/less\s+([\d,]+(?:\.\d+)?)/i);
  if (weak) return { amount: parseKsh(weak[1]), confident: false };
  return null;
}
