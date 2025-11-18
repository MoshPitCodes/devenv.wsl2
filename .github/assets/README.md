# Assets Directory

This directory contains visual assets for the WSL2 DevKit project.

## Directory Structure

```
.github/assets/
├── logo/           # Logo files (PNG, SVG)
├── pallet/         # Banner and color palette images
├── screenshots/    # Screenshots and demo images
└── README.md       # This file
```

## Asset Guidelines

### Logo (`logo/`)
- **Formats**: PNG, SVG
- **Naming**: `wsl-logo.png`, `wsl-logo.svg`
- **Usage**: Main project logo used in README header
- **Recommended Size**: 100px-200px for README display

### Pallet/Banner (`pallet/`)
- **Formats**: PNG, SVG
- **Naming**: `pallet-0.png`, `banner.png`
- **Usage**: Color palettes, banner images for README
- **Recommended Width**: 800px for README display

### Screenshots (`screenshots/`)
- **Formats**: PNG, JPG
- **Naming**: Use descriptive names like:
  - `setup-step-1.png`
  - `terminal-output.png`
  - `ansible-running.png`
  - `docker-verification.png`
- **Usage**: Documentation and guides
- **Recommended**: Crop to relevant content, use high resolution

## Current Assets

The project currently references these assets in [README.md](../../README.md):

- `./.github/assets/logo/wsl-logo.png` - Main logo (100px width)
- `./.github/assets/pallet/pallet-0.png` - Banner image (800px width)

## Adding New Assets

1. Place the file in the appropriate directory
2. Use descriptive, lowercase filenames with hyphens
3. Update documentation to reference the new asset
4. Commit both the asset and documentation changes

## Asset Attribution

If using third-party assets, ensure proper licensing and attribution:

```markdown
<!-- In README.md or relevant documentation -->
Logo adapted from [Source Name](url) under [License Type]
```

## File Size Guidelines

- Keep individual files under 500KB when possible
- Optimize images before committing:
  - PNG: Use tools like `pngcrush` or `optipng`
  - JPG: Use quality setting of 85-90
  - SVG: Remove unnecessary metadata

## Brand Colors

Document the project's color scheme here for consistency:

```
Primary: #FABD2F (Gold/Yellow)
Secondary: #B16286 (Purple)
Accent: #458588 (Blue)
Success: #98971A (Green)
Background: #282828 (Dark Gray)
```

These colors match the badge styling in the README.
