#!/bin/bash
awk '{print $6}' auth.log | sort | uniq -c | sort -nr