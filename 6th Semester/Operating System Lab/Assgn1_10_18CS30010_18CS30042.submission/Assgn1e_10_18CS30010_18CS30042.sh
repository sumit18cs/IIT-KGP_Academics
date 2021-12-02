#!/bin/bash

l=$#

if [[ $1 -lt 0 ]]; then
	echo "Enter a non-negative Number"
else
	if [ $l == 0 ]
	then
		< /dev/urandom tr -dc _A-Za-z0-9 | head -c16
	else
		< /dev/urandom tr -dc _A-Za-z0-9 | head -c$1
	fi
fi