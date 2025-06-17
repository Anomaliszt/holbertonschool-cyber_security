#!/bin/bash
find "$1" -type f -empty -exec chmod -R a=rwx "$1" {} \; 2>/dev/null
