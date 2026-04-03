# Branding Asset Structure

This directory holds application-level branding assets defined in [docs/branding.md](../../docs/branding.md).

## Subdirectories

- `logos/`: logomark, wordmark, app icon masters, notification icons.
- `icons/`: navigation icons, category icons, game icons, system glyphs.
- `badges/`: category badges, achievement badges, rank badges, overlays.
- `avatars/`: branded default profile avatars used during profile setup and fallback user identity.
- `onboarding/`: onboarding illustrations and splash artwork.
- `system/`: empty-state, error-state, loading, and notification thumbnails.

## Notes

- Use the naming convention from [docs/branding.md](../../docs/branding.md#105-naming-convention).
- Keep source-of-truth SVGs alongside exported PNGs where applicable.
- Store only production-ready assets here; work-in-progress source files should stay outside the app bundle.