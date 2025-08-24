#!/bin/bash

# OpenAPI Code Generation Script for ROMM iOS App
# This script generates Swift client code from the openapi.json file

set -e

# Configuration
PROJECT_ROOT="$(pwd)"
OPENAPI_JSON="$PROJECT_ROOT/openapi.json"
OUTPUT_DIR="$PROJECT_ROOT/romm/romm/Data/DataSources/API/OpenAPIs"
GENERATOR_VERSION="7.5.0"
PACKAGE_NAME="RommAPI"
PROJECT_NAME="romm"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting OpenAPI Code Generation${NC}"

# Check if openapi.json exists
if [ ! -f "$OPENAPI_JSON" ]; then
    echo -e "${RED}❌ Error: openapi.json not found at $OPENAPI_JSON${NC}"
    exit 1
fi

echo -e "${YELLOW}📄 Using OpenAPI spec: $OPENAPI_JSON${NC}"

# Check if openapi-generator is installed
if ! command -v openapi-generator &> /dev/null; then
    echo -e "${YELLOW}⚠️  openapi-generator not found. Installing via npm...${NC}"
    npm install -g @openapitools/openapi-generator-cli
fi

# Backup existing API directory if it exists
if [ -d "$OUTPUT_DIR" ]; then
    echo -e "${YELLOW}📦 Backing up existing API code...${NC}"
    cp -r "$OUTPUT_DIR" "$OUTPUT_DIR.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Remove old generated files
echo -e "${YELLOW}🧹 Cleaning old generated files...${NC}"
rm -rf "$OUTPUT_DIR"

# Generate Swift client
echo -e "${YELLOW}⚙️  Generating Swift client code...${NC}"

openapi-generator generate \
    -i "$OPENAPI_JSON" \
    -g swift5 \
    -o "$OUTPUT_DIR" \
    --package-name "$PACKAGE_NAME" \
    --additional-properties=projectName="$PROJECT_NAME" \
    --additional-properties=nonPublicApi=false \
    --additional-properties=objcCompatible=false \
    --additional-properties=responseAs=AsyncAwait \
    --additional-properties=library=urlsession \
    --additional-properties=useSPMFileStructure=false \
    --skip-validate-spec

# Move generated files to the correct structure
echo -e "${YELLOW}📁 Organizing generated files...${NC}"

if [ -d "$OUTPUT_DIR/$PACKAGE_NAME" ]; then
    # Move the generated Classes/OpenAPIs content to our desired location
    if [ -d "$OUTPUT_DIR/$PACKAGE_NAME/Classes/OpenAPIs" ]; then
        # Create the parent directory
        mkdir -p "$(dirname "$OUTPUT_DIR")"
        
        # Move the OpenAPIs content to replace the entire OpenAPIs directory
        mv "$OUTPUT_DIR/$PACKAGE_NAME/Classes/OpenAPIs" "$OUTPUT_DIR.tmp"
        rm -rf "$OUTPUT_DIR"
        mv "$OUTPUT_DIR.tmp" "$OUTPUT_DIR"
        
        # Clean up the temporary package structure
        rm -rf "$OUTPUT_DIR/../$PACKAGE_NAME" 2>/dev/null || true
        rm -rf "$OUTPUT_DIR/../.openapi-generator" 2>/dev/null || true
        rm -f "$OUTPUT_DIR/../.openapi-generator-ignore" 2>/dev/null || true
        rm -f "$OUTPUT_DIR/../Package.swift" 2>/dev/null || true
        rm -f "$OUTPUT_DIR/../README.md" 2>/dev/null || true
        rm -f "$OUTPUT_DIR/../git_push.sh" 2>/dev/null || true
        rm -f "$OUTPUT_DIR/../$PROJECT_NAME.podspec" 2>/dev/null || true
    fi
fi

echo -e "${GREEN}✅ API generation completed successfully!${NC}"
echo -e "${GREEN}📍 Generated files location: $OUTPUT_DIR${NC}"

# Display summary
if [ -d "$OUTPUT_DIR" ]; then
    API_COUNT=$(find "$OUTPUT_DIR/APIs" -name "*.swift" 2>/dev/null | wc -l || echo "0")
    MODEL_COUNT=$(find "$OUTPUT_DIR/Models" -name "*.swift" 2>/dev/null | wc -l || echo "0")
    
    echo -e "${GREEN}📊 Generation Summary:${NC}"
    echo -e "   • APIs: $API_COUNT files"
    echo -e "   • Models: $MODEL_COUNT files"
    echo -e ""
    echo -e "${YELLOW}⚠️  Next steps:${NC}"
    echo -e "   1. Open Xcode and add any new files to the project"
    echo -e "   2. Fix any compilation errors"
    echo -e "   3. Update your mappers if needed"
    echo -e "   4. Test the API integration"
else
    echo -e "${RED}❌ Error: Generated files not found in expected location${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Done!${NC}"