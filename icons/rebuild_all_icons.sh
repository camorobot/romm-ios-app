#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set paths relative to script location
ICONS_DIR="$SCRIPT_DIR"
PLATFORMS_DIR="$SCRIPT_DIR/../romm/romm/Assets.xcassets/platforms"

echo "================================================"
echo "  Updating Platform Icons (Preserving SVGs)"
echo "================================================"
echo ""

# Step 1: Analyze existing imagesets
echo "Step 1: Analyzing existing imagesets..."
existing_svgs=0
existing_pngs=0

for imageset in "$PLATFORMS_DIR"/*.imageset; do
    [ -d "$imageset" ] || continue
    if [ -f "$imageset"/*.svg ]; then
        ((existing_svgs++))
    elif [ -f "$imageset"/*.png ]; then
        ((existing_pngs++))
    fi
done

echo "  Found $existing_svgs existing SVG imagesets (will be preserved)"
echo "  Found $existing_pngs existing PNG imagesets (will be updated if new ICO available)"
echo ""

# Step 2: Import/Update SVG icons (Single Scale - Best Practice)
echo "Step 2: Importing SVG icons (Single Scale)..."
echo "  (Existing SVG imagesets will be preserved)"
cd "$ICONS_DIR"
svg_count=0

svg_upgraded=0

for svg_file in *.svg; do
    [ -f "$svg_file" ] || continue

    platform="${svg_file%.svg}"
    IMAGESET_DIR="${PLATFORMS_DIR}/${platform}.imageset"

    # Check what exists in the imageset
    has_existing_svg=false
    has_existing_png=false

    if [ -d "$IMAGESET_DIR" ]; then
        if [ -f "$IMAGESET_DIR"/*.svg ]; then
            has_existing_svg=true
        elif [ -f "$IMAGESET_DIR"/*.png ]; then
            has_existing_png=true
        fi
    fi

    # IMPORTANT: Preserve existing SVGs (don't replace SVG with SVG from /icons)
    if [ "$has_existing_svg" = true ]; then
        continue
    fi

    # If PNG exists, we'll replace it with the new SVG (SVG has higher priority)
    if [ "$has_existing_png" = true ]; then
        echo "  → Upgrading ${platform} from PNG to SVG"
        rm -f "$IMAGESET_DIR"/*.png
        ((svg_upgraded++))
    fi

    # Create imageset directory
    mkdir -p "$IMAGESET_DIR"

    # Copy SVG file
    cp "$svg_file" "$IMAGESET_DIR/"

    # Create Contents.json with Single Scale for SVG (Best Practice)
    cat > "${IMAGESET_DIR}/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "${svg_file}",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

    ((svg_count++))
done

svg_preserved=$((existing_svgs - svg_count))
echo "  ✓ Imported $svg_count new SVG icons"
if [ $svg_upgraded -gt 0 ]; then
    echo "  ✓ Upgraded $svg_upgraded PNG → SVG"
fi
echo "  ✓ Preserved $svg_preserved existing SVG icons"
echo ""

# Step 3: Convert ICO to PNG (for platforms without SVG)
echo "Step 3: Converting ICO to PNG (for platforms without SVG)..."
png_converted=0

mkdir -p "${ICONS_DIR}/converted_png"

for ico_file in *.ico; do
    [ -f "$ico_file" ] || continue

    platform="${ico_file%.ico}"
    svg_file="${platform}.svg"

    # Skip if SVG exists (SVG has priority) - FIX: Use full path
    if [ -f "${ICONS_DIR}/${svg_file}" ]; then
        continue
    fi

    # Skip problematic filenames with spaces
    if [[ "$platform" == *" "* ]]; then
        continue
    fi

    # Convert ICO to PNG using macOS sips
    png_output="${ICONS_DIR}/converted_png/${platform}.png"
    sips -s format png "$ico_file" --out "$png_output" >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        ((png_converted++))
    fi
done

echo "  ✓ Converted $png_converted ICO files to PNG"
echo ""

# Step 4: Import PNG icons (Single Scale - only for platforms without SVG)
echo "Step 4: Importing PNG icons (Single Scale - converted from ICO)..."
png_count=0

for png_file in converted_png/*.png; do
    [ -f "$png_file" ] || continue

    platform=$(basename "${png_file%.png}")
    IMAGESET_DIR="${PLATFORMS_DIR}/${platform}.imageset"

    # IMPORTANT: Skip if SVG imageset exists (SVGs have priority and should never be replaced!)
    if [ -d "$IMAGESET_DIR" ] && [ -f "$IMAGESET_DIR"/*.svg ]; then
        continue
    fi

    # Update existing PNG imageset or create new one
    mkdir -p "$IMAGESET_DIR"

    # Remove old PNG if it exists (we're updating it with new ICO conversion)
    rm -f "$IMAGESET_DIR"/*.png

    # Copy new PNG file
    cp "$png_file" "$IMAGESET_DIR/${platform}.png"

    # Create Contents.json for PNG with Single Scale (Best Practice)
    cat > "${IMAGESET_DIR}/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "${platform}.png",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

    ((png_count++))
done

png_updated=$png_count
echo "  ✓ Updated/Created $png_updated PNG icons (converted from ICO)"
echo ""

# Step 5: Summary
echo "================================================"
echo "  Summary"
echo "================================================"
total_count=$(find "$PLATFORMS_DIR" -maxdepth 1 -name "*.imageset" -type d | wc -l | tr -d ' ')
current_svgs=$(find "$PLATFORMS_DIR" -maxdepth 1 -name "*.imageset" -type d -exec sh -c 'test -f "{}"/*.svg && echo "svg"' \; | wc -l | tr -d ' ')
current_pngs=$(find "$PLATFORMS_DIR" -maxdepth 1 -name "*.imageset" -type d -exec sh -c 'test -f "{}"/*.png && echo "png"' \; | wc -l | tr -d ' ')

echo "  Total imagesets: $total_count"
echo ""
echo "  SVG icons (Single Scale):"
echo "    - Existing (preserved): $svg_preserved"
echo "    - New (imported): $svg_count"
echo "    - Total: $current_svgs"
echo ""
echo "  PNG icons (Single Scale, from ICO):"
echo "    - Updated/Created: $png_updated"
echo "    - Total: $current_pngs"
echo ""
echo "  ICO conversions: $png_converted"
echo ""
echo "✅ Done! Platform icons updated successfully."
echo ""
echo "IMPORTANT: Icon priority system:"
echo "  1. Existing SVGs are NEVER replaced (highest priority)"
echo "  2. New SVGs will replace existing PNGs (upgrade)"
echo "  3. New ICO files update PNGs (if no SVG exists)"
echo ""
echo "Note: All icons use Single Scale (best practice)"
echo "      iOS automatically scales for all screen resolutions (@1x, @2x, @3x)"
