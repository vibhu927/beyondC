# BeyondC Copilot Notes

## Design System
- Follow `DESIGN_SYSTEM.md` at the repo root as the source of truth for all UI work.
- New screens and components must use the canonical minimal palette: off-white, white, neon green, dark green, gray, and black.
- The bottom navbar should stay centered at about 85% width, use a full rounded dark green pill, and use a circular neon green active tab.

## Shared Constants
- `mobile/lib/core/constants/india_locations.dart`: Canonical India states + city mapping for Flutter forms and filters.
- `backend/lib/constants/india-locations.ts`: Canonical India states + city mapping for web onboarding and API-side validation/helpers.

## Shared Widgets
- `mobile/lib/widgets/inputs/bc_location_picker.dart`: Reusable dependent State/City picker with `Other` city fallback and manual city input.

## Usage Guidance
- Use `BCLocationPicker` for signup, profile edit, campaign target location, and filter forms.
- Keep profile `state`/`city` in `profiles` table; do not duplicate in role-specific profile tables.
- For campaign targeting, use `target_state`/`target_city`; `null` means Pan India.

## Agency Role
- Add `agency` to `profiles.role` allowed values and treat as a distinct portal alongside `creator` and `brand`.
- Key tables: `agency_profiles`, `agency_creators`, `agency_pitches`. Follow existing table patterns from `creator_profiles` and `brand_profiles`.
- One active agency per creator enforced at API level (`agency_creators` status must be `accepted`).
- Agency credits: use same `credit_transactions` system as brands; deduct agency credits only when the other side accepts AND the involved creator was a partnered creator at the time of acceptance.
- Discovery: add `agency_discovery_view` with same privacy constraints as `creator_discovery_view` (no contact/full name until match).
- Routes: Add agency routes to `mobile` router (e.g., `agencyHome`, `agencyCreators`, `agencyDiscover`, `agencyProfile`).
- Business rules: agency can pitch brands, bid on campaigns (with optional `assigned_creator_id`), and invite creators to roster (requires creator acceptance).
