#!/bin/bash
find "$1" -type f -mtime -1 \( -perm -4000 -o -perm -2000 \) -exec ls -ldb {} \;
