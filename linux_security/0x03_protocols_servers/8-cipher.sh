#!/bin/bash
nmap -p 443 --script ssl-enum-ciphers $1
