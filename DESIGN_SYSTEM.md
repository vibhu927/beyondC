# BeyondC Design System

This file is the source of truth for all UI work in this repo.
Every agent should follow these rules before adding or changing screens, components, or motion.

## Core Direction

- Visual style: clean, premium, minimal, and professional.
- Base palette: off-white backgrounds, white cards, neon green accents, dark green navigation surfaces.
- Avoid colorful UI noise. Do not introduce extra accent colors unless a feature absolutely requires it and the design file is updated first.
- Use the neon green only for emphasis, active states, primary actions, and key data highlights.

## Canonical Light Mode Palette

- `#C8FF00` Neon green
- `#0F5B3B` Dark green
- `#F6F5F1` Off-white background
- `#FFFFFF` White surfaces
- `#111111` Black text
- `#6B6B6B` Gray text

## Canonical Dark Mode Palette

- `#C8FF00` Neon green accent
- `#08110D` Dark background
- `#0F1B16` Dark surface
- `#163326` Deep green surface and navigation tint
- `#F5F5F1` Off-white text
- `#B0B0B0` Gray text

## Layout Rules

- Backgrounds should stay soft and quiet.
- Cards should be white in light mode and a restrained dark surface in dark mode.
- Prefer rounded corners, gentle elevation, and compact spacing.
- Keep layouts airy and uncluttered.
- Use the neon green sparingly so it feels premium, not loud.

## Bottom Navbar Rules

- Match the provided reference style closely.
- Keep the navbar centered at roughly 85% of screen width.
- Use a dark green pill-shaped background with full rounding on both ends.
- Use a neon green circular active indicator.
- Keep icons simple, rounded, and visually similar to the reference.
- Do not add extra chromatic accents to the navbar.
- The navbar should feel embedded, polished, and consistent across portals.

## Typography Rules

- Use black or dark green for primary text in light mode.
- Use off-white for primary text in dark mode.
- Use gray for secondary copy, hints, and metadata.
- Headings should be bold but not overly heavy.

## Component Rules

- Cards: white/off-white in light mode, dark green-tinted surface in dark mode.
- Buttons: primary actions use neon green or dark green depending on contrast needs.
- Inputs: minimal borders, no bright outlines unless focused.
- Chips and badges: keep them restrained and mostly monochrome with neon only for emphasis.

## Motion Rules

- Motion should be subtle and purposeful.
- Use small scale, fade, and slide transitions.
- Avoid playful or bouncy motion.

## Hard Constraints

- Do not introduce pink, blue, purple, or orange as active design accents in new work.
- Do not use gradients unless they are subtle and still fit the minimal palette.
- Do not make dark mode visually louder than light mode.
- If a screen needs a new accent, update this file first.
