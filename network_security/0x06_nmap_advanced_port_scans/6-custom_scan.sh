#!/bin/bash
sudo nmap -sS --scanflags=TCP -p $2 -oN custom_scan.txt >/dev/null $1 2>&1
