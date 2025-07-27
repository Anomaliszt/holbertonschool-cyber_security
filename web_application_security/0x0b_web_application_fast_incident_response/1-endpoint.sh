#!/bin/bash
grep -E '/' logs.txt | uniq -c | sort -nr | head -n 1 | awk '{print $8}'