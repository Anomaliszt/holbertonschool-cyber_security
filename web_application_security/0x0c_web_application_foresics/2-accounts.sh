#!/bin/bash
tail -n 1000 auth.log | grep -E "root" | sort | uniq -c | sort -nr | head -n 1 | awk '{print $12}'