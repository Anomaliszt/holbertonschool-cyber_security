#!/bin/bash
curl -X POST "$2" -H "Content-Type: application/x-www-form-urlencoded" -H "Host: $1" -d "$3"