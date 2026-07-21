#!/bin/bash

# MEDDEFENSE CERTIFICATE SIGNING REQUEST GENERATOR
# Purpose: Generate CSR for patient portal certificate renewal
# Usage: ./10-generate_csr.sh [output_dir]

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

OUTPUT_DIR=${1:-.}

if [[ ! -d $OUTPUT_DIR ]]; then
    mkdir -p "$OUTPUT_DIR"
fi

echo -e "${BLUE}========== MEDDEFENSE CSR GENERATION ==========${NC}"
echo ""

# Step 1: Key Algorithm Selection
echo -e "${YELLOW}STEP 1: Key Generation${NC}"
echo "Recommended: RSA-2048 (security: 128-bit equivalent, compatibility: excellent, performance: good)"
echo ""

# Generate RSA-2048 key
echo -e "${YELLOW}Generating RSA-2048 private key...${NC}"
openssl genrsa -out "$OUTPUT_DIR/portal_key.pem" 2048 > /dev/null 2>&1

if [[ -f "$OUTPUT_DIR/portal_key.pem" ]]; then
    KEY_SIZE=$(stat -f%z "$OUTPUT_DIR/portal_key.pem" 2>/dev/null || stat -c%s "$OUTPUT_DIR/portal_key.pem")
    echo -e "${GREEN}✓ Private key generated: $OUTPUT_DIR/portal_key.pem ($KEY_SIZE bytes)${NC}"
else
    echo -e "${RED}ERROR: Failed to generate private key${NC}"
    exit 1
fi

# Step 2: CSR Generation
echo ""
echo -e "${YELLOW}STEP 2: Certificate Signing Request${NC}"

# Create config with SANs
cat > "$OUTPUT_DIR/csr.conf" << 'SSLCONF'
[req]
default_bits = 2048
default_md = sha256
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = US
ST = California
L = San Francisco
O = MedDefense Health Systems
OU = Information Technology
CN = portal.meddefense.local

[v3_req]
subjectAltName = DNS:portal.meddefense.local,DNS:www.portal.meddefense.local,DNS:portal
SSLCONF

echo -e "${YELLOW}Generating CSR with Subject Alternative Names...${NC}"
openssl req -new \
    -key "$OUTPUT_DIR/portal_key.pem" \
    -out "$OUTPUT_DIR/portal.csr" \
    -config "$OUTPUT_DIR/csr.conf" 2>/dev/null

if [[ -f "$OUTPUT_DIR/portal.csr" ]]; then
    CSR_SIZE=$(stat -f%z "$OUTPUT_DIR/portal.csr" 2>/dev/null || stat -c%s "$OUTPUT_DIR/portal.csr")
    echo -e "${GREEN}✓ CSR generated: $OUTPUT_DIR/portal.csr ($CSR_SIZE bytes)${NC}"
else
    echo -e "${RED}ERROR: Failed to generate CSR${NC}"
    exit 1
fi

# Step 3: CSR Inspection
echo ""
echo -e "${YELLOW}STEP 3: CSR Verification${NC}"
echo ""

openssl req -text -noout -in "$OUTPUT_DIR/portal.csr"

echo ""
echo -e "${GREEN}✓ CSR Generation Complete${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Submit CSR to Certificate Authority (DigiCert recommended)"
echo "2. CA will verify organizational identity (OV validation)"
echo "3. CA will issue certificate"
echo "4. Install certificate on portal-srv-01:"
echo "   sudo cp portal_cert.crt /etc/ssl/certs/"
echo "   sudo cp portal_key.pem /etc/ssl/private/"
echo "5. Update Apache configuration to reference new cert"
echo "6. Reload Apache: sudo systemctl reload apache2"
echo "7. Verify: echo | openssl s_client -servername portal.meddefense.local -connect portal.meddefense.local:443 2>/dev/null | openssl x509 -noout -dates"
echo ""
echo -e "${BLUE}Files Created:${NC}"
echo "  - $OUTPUT_DIR/portal_key.pem (KEEP SECRET)"
echo "  - $OUTPUT_DIR/portal.csr (submit to CA)"
echo "  - $OUTPUT_DIR/csr.conf (reference only)"
