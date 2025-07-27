#!/bin/bash
grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' logs.txt | uniq -c | sort -nr | head -n 1 | awk '{print $2}'