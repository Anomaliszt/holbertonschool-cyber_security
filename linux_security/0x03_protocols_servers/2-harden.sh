#!/bin/bash
find / -type d -perm -0002 -xdev exec chmod o-w {} + \; 2>/dev/null
