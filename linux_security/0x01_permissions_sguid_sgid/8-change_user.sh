#!/bin/bash
find "$1" -type f -user user2 -exec chown -R user3 "$1" {} \; 2>/dev/null