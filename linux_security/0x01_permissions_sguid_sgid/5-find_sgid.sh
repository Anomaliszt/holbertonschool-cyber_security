#!/bin/bash
find "$1" -perm -6000 -exec ls {} \; 2>/dev/null
