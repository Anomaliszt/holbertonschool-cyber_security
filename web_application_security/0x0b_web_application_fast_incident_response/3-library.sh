#!/bin/bash
cat logs.txt | uniq -c | sort -nr | head -n 1 | awk '{print $13}' | tr -d '"'