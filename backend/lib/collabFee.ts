// Collab fee calculation based on brand size
// All amounts in paise (₹1 = 100 paise)

export const COLLAB_FEES = {
  micro: { min: 1000, max: 3000 },  // ₹10–₹30
  mid:   { min: 5000, max: 10000 }, // ₹50–₹100
  big:   { min: 15000, max: 30000 } // ₹150–₹300
} as const;

export type BrandSize = keyof typeof COLLAB_FEES;

/**
 * Calculate the collab fee for a creator accepting a collab
 * @param brandSize - Size of the brand ('micro', 'mid', or 'big')
 * @returns Fee amount in paise
 */
export function getCollabFee(brandSize: BrandSize): number {
  const range = COLLAB_FEES[brandSize];
  // Use midpoint for now, can be made dynamic later
  return Math.floor((range.min + range.max) / 2);
}

/**
 * Convert paise to rupees for display
 */
export function paiseToRupees(paise: number): number {
  return paise / 100;
}

/**
 * Convert rupees to paise for storage
 */
export function rupeesToPaise(rupees: number): number {
  return Math.round(rupees * 100);
}
