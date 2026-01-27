// Helper to format currency consistently across templates
export function formatCurrency(
  value: number | string | undefined,
  locale = "es-MX",
  currency = "MXN",
) {
  const n = Number(value ?? 0);
  const safe = Number.isFinite(n) ? n : 0;
  return new Intl.NumberFormat(locale, { style: "currency", currency }).format(safe);
}
