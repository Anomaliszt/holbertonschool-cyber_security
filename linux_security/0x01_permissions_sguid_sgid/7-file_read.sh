#!/bin/bash
find "$1" -type f -exec chmod -R o=r "$1" {} \; 2>/dev/null
