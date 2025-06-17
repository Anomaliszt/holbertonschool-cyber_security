#!/bin/bash
echo -n $1 | sha256sum | awk '{print $1}' > 1_hash.txt
