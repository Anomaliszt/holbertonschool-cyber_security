#!/bin/bash
useradd "$1"
echo "$1:$2" | chpasswd
