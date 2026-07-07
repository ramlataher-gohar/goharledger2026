export function todayStr(): string {
  return new Date().toISOString().split('T')[0];
}

export function formatKES(amount: number | null | undefined): string {
  if (amount === null || amount === undefined) return '0';
  return amount.toLocaleString('en-KE', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  });
}

export function formatDate(dateStr: string | null | undefined): string {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  return d.toLocaleDateString('en-KE', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
}

export function formatDateShort(dateStr: string | null | undefined): string {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  return d.toLocaleDateString('en-KE', {
    month: 'short',
    day: 'numeric',
  });
}

export function getMonthLabel(dateStr: string): string {
  const d = new Date(dateStr + '-01');
  return d.toLocaleDateString('en-KE', { year: 'numeric', month: 'long' });
}

