#!/bin/bash

# MEDDEFENSE DIGITAL SIGNATURE TOOL
# Purpose: Sign files and verify signatures using RSA keys
# Usage: ./5-sign_verify.sh <mode> <file> [signature] [public_key]
# Modes: sign, verify

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Validate at least 2 arguments
if [[ $# -lt 2 ]]; then
    echo -e "${RED}ERROR: Minimum 2 arguments required${NC}"
    echo "Usage for signing: $0 sign <file> [private_key]"
    echo "Usage for verification: $0 verify <file> <signature> <public_key>"
    exit 1
fi

MODE=$1
FILE=$2

# Mode selection with case statement (sign or verify)
case $MODE in
    sign) MODE_VALID=true ;;
    verify) MODE_VALID=true ;;
    *) echo -e "${RED}ERROR: Invalid mode: $MODE (must be 'sign' or 'verify')${NC}"; exit 1 ;;
esac

# Validate mode was recognized
if [[ "$MODE_VALID" != "true" ]]; then
    echo -e "${RED}ERROR: Mode validation failed${NC}"
    exit 1
fi

# Sign mode
if [[ $MODE == "sign" ]]; then
    PRIVATE_KEY=${3:-"private.pem"}
    
    if [[ ! -f $FILE ]]; then
        echo -e "${RED}ERROR: File not found: $FILE${NC}"
        exit 1
    fi
    
    if [[ ! -f $PRIVATE_KEY ]]; then
        echo -e "${RED}ERROR: Private key not found: $PRIVATE_KEY${NC}"
        exit 1
    fi
    
    SIG_FILE="${FILE}.sig"
    
    echo -e "${YELLOW}Signing file with private key...${NC}"
    openssl dgst -sha256 -sign "$PRIVATE_KEY" "$FILE" > "$SIG_FILE"
    
    if [[ -f $SIG_FILE ]]; then
        echo -e "${GREEN}✓ Signature created${NC}"
        echo -e "${GREEN}File: $FILE${NC}"
        echo -e "${GREEN}Signature: $SIG_FILE${NC}"
        echo -e "${GREEN}Size: $(stat -f%z "$SIG_FILE" 2>/dev/null || stat -c%s "$SIG_FILE") bytes${NC}"
        exit 0
    else
        echo -e "${RED}ERROR: Failed to create signature${NC}"
        exit 1
    fi

# Verify mode
elif [[ $MODE == "verify" ]]; then
    if [[ $# -ne 4 ]]; then
        echo -e "${RED}ERROR: verify mode requires 4 arguments${NC}"
        echo "Usage: $0 verify <file> <signature> <public_key>"
        exit 1
    fi
    
    SIGNATURE=$3
    PUBLIC_KEY=$4
    
    if [[ ! -f $FILE ]]; then
        echo -e "${RED}ERROR: File not found: $FILE${NC}"
        exit 1
    fi
    
    if [[ ! -f $SIGNATURE ]]; then
        echo -e "${RED}ERROR: Signature file not found: $SIGNATURE${NC}"
        exit 1
    fi
    
    if [[ ! -f $PUBLIC_KEY ]]; then
        echo -e "${RED}ERROR: Public key not found: $PUBLIC_KEY${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Verifying signature...${NC}"
    
    if openssl dgst -sha256 -verify "$PUBLIC_KEY" -signature "$SIGNATURE" "$FILE" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ SIGNATURE VALID${NC}"
        echo -e "${GREEN}File: $FILE${NC}"
        echo -e "${GREEN}Signer verified with public key: $PUBLIC_KEY${NC}"
        exit 0
    else
        echo -e "${RED}✗ SIGNATURE INVALID${NC}"
        echo -e "${RED}File: $FILE${NC}"
        echo -e "${RED}Signature verification failed with key: $PUBLIC_KEY${NC}"
        exit 1
    fi

else
    echo -e "${RED}ERROR: Invalid mode: $MODE (must be 'sign' or 'verify')${NC}"
    exit 1
fi
