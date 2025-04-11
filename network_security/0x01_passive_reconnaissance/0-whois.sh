#!/bin/bash
whois "$1" | awk -F ': +' 'BEGIN{OFS=","}/^Registrant |^Admin |^Tech /{print $1,$2}' > "${1}.csv"