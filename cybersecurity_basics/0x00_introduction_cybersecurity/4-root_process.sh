#!/bin/bash
ps aux | grep "$1" | grep -v "vsz" | grep -v "rss"