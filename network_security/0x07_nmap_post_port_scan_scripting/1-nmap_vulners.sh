#!/bin/bash
nmap --script vulners $1 -p 80,443
