#!/bin/bash
sudo nmap -sF -Pn -p 80-85 -T2 -f $1
