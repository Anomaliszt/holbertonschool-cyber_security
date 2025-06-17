#!/bin/bash
find "$1" -perm -4000 -exec ls {} \; 2>/dev/null
