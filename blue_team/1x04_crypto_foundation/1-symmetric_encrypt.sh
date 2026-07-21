#!/bin/bash

# MEDDEFENSE SYMMETRIC ENCRYPTION TOOL
# Purpose: Encrypt files using AES-256 in CBC or GCM mode
# Usage: ./1-symmetric_encrypt.sh <input_file> <output_file> <mode>
# Modes: cbc, gcm

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Validate arguments
if [[ $# -ne 3 ]]; then
    echo -e "${RED}ERROR: Requires 3 arguments${NC}"
    echo "Usage: $0 <input_file> <output_file> <mode>"
    echo "Modes: cbc, gcm"
    exit 1
fi

INPUT_FILE=$1
OUTPUT_FILE=$2
MODE=$3

# Validate input file exists
if [[ ! -f $INPUT_FILE ]]; then
    echo -e "${RED}ERROR: Input file does not exist: $INPUT_FILE${NC}"
    exit 1
fi

# Validate mode
if [[ $MODE != "cbc" && $MODE != "gcm" ]]; then
    echo -e "${RED}ERROR: Invalid mode: $MODE (must be 'cbc' or 'gcm')${NC}"
    exit 1
fi

# Prompt for password
read -s -p "Enter encryption password: " PASSWORD
echo ""
read -s -p "Confirm password: " PASSWORD_CONFIRM
echo ""

if [[ $PASSWORD != $PASSWORD_CONFIRM ]]; then
    echo -e "${RED}ERROR: Passwords do not match${NC}"
    exit 1
fi

# Get file size
FILE_SIZE=$(stat -f%z "$INPUT_FILE" 2>/dev/null || stat -c%s "$INPUT_FILE" 2>/dev/null)
echo -e "${YELLOW}Input file size: $(numfmt --to=iec-i --suffix=B $FILE_SIZE 2>/dev/null || echo $FILE_SIZE' bytes')${NC}"

# Encrypt based on mode
START_TIME=$(date +%s%N)

if [[ $MODE == "cbc" ]]; then
    echo -e "${YELLOW}Encrypting with AES-256-CBC...${NC}"
    openssl enc -aes-256-cbc -salt -in "$INPUT_FILE" -out "$OUTPUT_FILE" -k "$PASSWORD"
    CIPHER="AES-256-CBC"
elif [[ $MODE == "gcm" ]]; then
    echo -e "${YELLOW}Encrypting with AES-256-GCM...${NC}"
    openssl enc -aes-256-gcm -salt -in "$INPUT_FILE" -out "$OUTPUT_FILE" -k "$PASSWORD"
    CIPHER="AES-256-GCM"
fi

END_TIME=$(date +%s%N)
DURATION_MS=$(( (END_TIME - START_TIME) / 1000000 ))

# Verify output file
if [[ -f $OUTPUT_FILE ]]; then
    OUTPUT_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null)
    echo -e "${GREEN}✓ Encryption successful${NC}"
    echo -e "${GREEN}Cipher: $CIPHER${NC}"
    echo -e "${GREEN}Output file: $OUTPUT_FILE${NC}"
    echo -e "${GREEN}Output size: $(numfmt --to=iec-i --suffix=B $OUTPUT_SIZE 2>/dev/null || echo $OUTPUT_SIZE' bytes')${NC}"
    echo -e "${GREEN}Encryption time: ${DURATION_MS}ms${NC}"
    exit 0
else
    echo -e "${RED}ERROR: Encryption failed${NC}"
    exit 1
fi
