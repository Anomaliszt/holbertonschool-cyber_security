#!/bin/bash

# MEDDEFENSE INTEGRITY VERIFICATION TOOL
# Purpose: Verify file integrity using SHA-256 hashes
# Usage: ./3-hash_verify.sh <file_path> <expected_hash>

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Validate arguments
if [[ $# -ne 2 ]]; then
    echo -e "${RED}ERROR: Requires 2 arguments${NC}"
    echo "Usage: $0 <file_path> <expected_hash>"
    echo ""
    echo "Example: $0 patient_records.sql 5d41402abc4b2a76b9719d911017c592"
    exit 1
fi

FILE_PATH=$1
EXPECTED_HASH=$2

# Validate file exists
if [[ ! -f $FILE_PATH ]]; then
    echo -e "${RED}INTEGRITY FAILED - File not found: $FILE_PATH${NC}"
    exit 1
fi

# Normalize hash to lowercase
EXPECTED_HASH=$(echo "$EXPECTED_HASH" | tr '[:upper:]' '[:lower:]')

# Compute SHA-256 hash
ACTUAL_HASH=$(sha256sum "$FILE_PATH" 2>/dev/null | awk '{print $1}' | tr '[:upper:]' '[:lower:]')

if [[ -z $ACTUAL_HASH ]]; then
    echo -e "${RED}INTEGRITY FAILED - Could not compute hash${NC}"
    exit 1
fi

# Compare hashes
if [[ $ACTUAL_HASH == $EXPECTED_HASH ]]; then
    echo -e "${GREEN}INTEGRITY OK${NC}"
    echo -e "${GREEN}File: $FILE_PATH${NC}"
    echo -e "${GREEN}Hash: $ACTUAL_HASH${NC}"
    exit 0
else
    echo -e "${RED}INTEGRITY FAILED${NC}"
    echo -e "${RED}File: $FILE_PATH${NC}"
    echo -e "${RED}expected $EXPECTED_HASH${NC}"
    echo -e "${RED}got $ACTUAL_HASH${NC}"
    exit 1
fi
