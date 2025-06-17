#!/bin/bash
hashcat -a 1 -m 0 $1 $2 --stdout 
