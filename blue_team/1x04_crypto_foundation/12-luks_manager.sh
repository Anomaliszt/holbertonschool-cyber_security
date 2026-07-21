#!/bin/bash

# MEDDEFENSE LUKS ENCRYPTION MANAGER
# Purpose: Create, open, close LUKS-encrypted volumes
# Usage: ./12-luks_manager.sh <mode> <volume_name> [size_mb]
# Modes: create, open, close

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Validate arguments (check sudo access for LUKS commands if needed)
if [[ $# -lt 2 ]]; then
    echo -e "${RED}ERROR: Minimum 2 arguments required${NC}"
    echo "Usage: $0 <mode> <volume_name> [size_mb]"
    echo ""
    echo "Modes:"
    echo "  create <volume_name> <size_mb>  Create a new LUKS volume"
    echo "  open <volume_name>               Open and mount LUKS volume"
    echo "  close <volume_name>              Unmount and close LUKS volume"
    echo ""
    echo "Example: $0 create backup_vol 500"
    exit 1
fi

MODE=$1
VOLUME_NAME=$2
SIZE_MB=${3:-500}
IMAGE_FILE="${VOLUME_NAME}.img"
MOUNT_POINT="/mnt/${VOLUME_NAME}"

# CREATE MODE
if [[ $MODE == "create" ]]; then
    if [[ ! $SIZE_MB =~ ^[0-9]+$ ]]; then
        echo -e "${RED}ERROR: Size must be a number in MB${NC}"
        exit 1
    fi
    
    if [[ -f $IMAGE_FILE ]]; then
        echo -e "${RED}ERROR: Volume file already exists: $IMAGE_FILE${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}========== CREATING LUKS VOLUME ==========${NC}"
    echo -e "${YELLOW}Volume name: $VOLUME_NAME${NC}"
    echo -e "${YELLOW}Size: ${SIZE_MB}MB${NC}"
    echo ""
    
    # Create sparse image file
    echo -e "${YELLOW}Step 1: Creating ${SIZE_MB}MB image file...${NC}"
    dd if=/dev/zero of="$IMAGE_FILE" bs=1M count="$SIZE_MB" status=progress
    
    # Format with LUKS
    echo ""
    echo -e "${YELLOW}Step 2: Formatting with LUKS encryption...${NC}"
    sudo cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --key-size 512 "$IMAGE_FILE"
    
    # Open volume
    echo ""
    echo -e "${YELLOW}Step 3: Opening encrypted volume...${NC}"
    sudo cryptsetup luksOpen "$IMAGE_FILE" "$VOLUME_NAME"
    
    # Create filesystem
    echo ""
    echo -e "${YELLOW}Step 4: Creating ext4 filesystem...${NC}"
    sudo mkfs.ext4 "/dev/mapper/$VOLUME_NAME"
    
    # Create mount point and mount
    echo ""
    echo -e "${YELLOW}Step 5: Mounting volume...${NC}"
    mkdir -p "$MOUNT_POINT"
    sudo mount "/dev/mapper/$VOLUME_NAME" "$MOUNT_POINT"
    
    # Verify
    echo ""
    echo -e "${GREEN}✓ LUKS volume created successfully${NC}"
    echo -e "${GREEN}Image file: $IMAGE_FILE${NC}"
    echo -e "${GREEN}Mount point: $MOUNT_POINT${NC}"
    echo -e "${GREEN}Status: OPEN and MOUNTED${NC}"
    echo ""
    df -h "$MOUNT_POINT"

# OPEN MODE
elif [[ $MODE == "open" ]]; then
    if [[ ! -f $IMAGE_FILE ]]; then
        echo -e "${RED}ERROR: Volume file not found: $IMAGE_FILE${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}========== OPENING LUKS VOLUME ==========${NC}"
    echo -e "${YELLOW}Volume: $VOLUME_NAME${NC}"
    echo ""
    
    # Check if already open
    if dmsetup info "/dev/mapper/$VOLUME_NAME" > /dev/null 2>&1; then
        echo -e "${YELLOW}Volume already open${NC}"
    else
        echo -e "${YELLOW}Opening encrypted volume...${NC}"
        sudo cryptsetup luksOpen "$IMAGE_FILE" "$VOLUME_NAME"
    fi
    
    # Create mount point if needed
    mkdir -p "$MOUNT_POINT"
    
    # Check if already mounted
    if mountpoint -q "$MOUNT_POINT"; then
        echo -e "${YELLOW}Volume already mounted at $MOUNT_POINT${NC}"
    else
        echo -e "${YELLOW}Mounting volume...${NC}"
        sudo mount "/dev/mapper/$VOLUME_NAME" "$MOUNT_POINT"
    fi
    
    echo ""
    echo -e "${GREEN}✓ Volume opened and mounted${NC}"
    echo -e "${GREEN}Mount point: $MOUNT_POINT${NC}"
    echo ""
    df -h "$MOUNT_POINT"

# CLOSE MODE
elif [[ $MODE == "close" ]]; then
    echo -e "${BLUE}========== CLOSING LUKS VOLUME ==========${NC}"
    echo -e "${YELLOW}Volume: $VOLUME_NAME${NC}"
    echo ""
    
    # Check if mounted and unmount
    if mountpoint -q "$MOUNT_POINT"; then
        echo -e "${YELLOW}Unmounting $MOUNT_POINT...${NC}"
        sudo umount "$MOUNT_POINT"
    else
        echo -e "${YELLOW}Volume not mounted${NC}"
    fi
    
    # Check if open and close
    if dmsetup info "/dev/mapper/$VOLUME_NAME" > /dev/null 2>&1; then
        echo -e "${YELLOW}Closing encrypted volume...${NC}"
        sudo cryptsetup luksClose "$VOLUME_NAME"
    else
        echo -e "${YELLOW}Volume not open${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}✓ Volume closed${NC}"
    echo -e "${GREEN}Data is now encrypted and inaccessible${NC}"

else
    echo -e "${RED}ERROR: Invalid mode: $MODE${NC}"
    echo "Valid modes: create, open, close"
    exit 1
fi
