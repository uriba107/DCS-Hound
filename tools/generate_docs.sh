#!/bin/bash

# HOUND Documentation Generator Script
# Wrapper script for generate_md_docs.py

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
VERBOSE=false
HELP=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            HELP=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Show help
if [ "$HELP" = true ]; then
    echo "HOUND Documentation Generator"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -v, --verbose    Enable verbose output"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "This script generates AI-optimized Markdown documentation from LDOC comments"
    echo "in the HOUND ELINT system source files."
    echo ""
    echo "Generated files:"
    echo "  - docs/generated/hound_full_api.md    - Complete API documentation"
    echo "  - docs/generated/hound_public_api.md  - Public API documentation only"
    exit 0
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if Python script exists
PYTHON_SCRIPT="$SCRIPT_DIR/generate_md_docs.py"
if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo -e "${RED}Error: Python script not found at $PYTHON_SCRIPT${NC}"
    exit 1
fi

# Check if source directory exists
SRC_DIR="$SCRIPT_DIR/../src"
if [ ! -d "$SRC_DIR" ]; then
    echo -e "${RED}Error: Source directory not found at $SRC_DIR${NC}"
    exit 1
fi

# Run the documentation generator
echo -e "${BLUE}HOUND Documentation Generator${NC}"
echo -e "${BLUE}=============================${NC}"

if [ "$VERBOSE" = true ]; then
    echo -e "${YELLOW}Running in verbose mode...${NC}"
    python3 "$PYTHON_SCRIPT" --verbose
else
    echo -e "${YELLOW}Generating documentation...${NC}"
    python3 "$PYTHON_SCRIPT"
fi

# Check if generation was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Documentation generated successfully!${NC}"
    echo ""
    echo "Generated files:"
    echo -e "  ${BLUE}Public API:${NC}       docs/HOUND_API_REFERENCE.md"
    echo -e "  ${BLUE}Developer API:${NC}    docs/dev/DEVELOPER_API_REFERENCE.md"
    echo ""
    echo "The HOUND_API_REFERENCE.md is optimized for AI agents and contains the public API"
    echo "that users need to interact with HOUND. The DEVELOPER_API_REFERENCE.md contains"
    echo "comprehensive internal documentation for developers working on HOUND."
else
    echo -e "${RED}✗ Documentation generation failed!${NC}"
    exit 1
fi
