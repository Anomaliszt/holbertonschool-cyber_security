#!/bin/bash
grep "useradd" auth.log | awk '{print $8}' | sed 's/name=//' | sed 's/,$//'| sort | uniq | paste -sd ","
