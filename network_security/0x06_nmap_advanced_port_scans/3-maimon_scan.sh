#!/bin/bash
sudo nmap -sM -p http,https,ftp,ssh,telnet -vv $1
