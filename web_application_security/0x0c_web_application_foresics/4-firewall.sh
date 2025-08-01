#!/bin/bash
grep -E "iptables" auth.log | grep "A INPUT" | wc -l

