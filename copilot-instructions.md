# BeyondC Copilot Notes

## Shared Constants
- `mobile/lib/core/constants/india_locations.dart`: Canonical India states + city mapping for Flutter forms and filters.
- `backend/lib/constants/india-locations.ts`: Canonical India states + city mapping for web onboarding and API-side validation/helpers.

## Shared Widgets
- `mobile/lib/widgets/inputs/bc_location_picker.dart`: Reusable dependent State/City picker with `Other` city fallback and manual city input.

## Usage Guidance
- Use `BCLocationPicker` for signup, profile edit, campaign target location, and filter forms.
- Keep profile `state`/`city` in `profiles` table; do not duplicate in role-specific profile tables.
- For campaign targeting, use `target_state`/`target_city`; `null` means Pan India.
