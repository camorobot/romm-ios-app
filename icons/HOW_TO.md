# Platform Icons Setup

## How to Update Platform Icons

1. Copy icon files (SVG and ICO) from the official RomM repository:
   https://github.com/rommapp/romm/tree/master/frontend/assets/platforms

2. Place the icon files in this directory (`icons/`)

3. Run the import script:
   ```bash
   ./rebuild_all_icons.sh
   ```

The script will automatically:
- Import SVG icons with priority (best quality, vector graphics)
- Convert ICO files to PNG format when no SVG is available
- Update the Xcode asset catalog with all platform icons
- Preserve existing SVG icons (never replaces them)
- Upgrade PNG icons to SVG when new SVG files are added

## Important Notes

- **SVG files have highest priority** - they will never be replaced
- ICO files are automatically converted to PNG (256×256)
- All icons use Single Scale for optimal iOS rendering
- The asset catalog is located at: `romm/romm/Assets.xcassets/platforms/`
