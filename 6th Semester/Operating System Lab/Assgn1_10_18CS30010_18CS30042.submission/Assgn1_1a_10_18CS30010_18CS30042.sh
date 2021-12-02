#!/bin/bash

gcd(){
    `! (( $1 % $2 )) && return $2 || gcd $2 $(( $1 % $2 ))`
}
text=("$@")
IFS=','
read -a array <<< "$text"
length=${#array[@]}
if [ $length -lt 10  -a  $length -ge 1 ]
then
	for (( i = 0; i < length; i++ ))
	do
		if [ ${array[i]} -lt 0 ]
		then
			array[i]=`expr ${array[i]} \* -1 `
		fi
	done
	gcd_value=${array[0]}
	for (( i = 1; i < length; i++ ))
	do
		gcd "$gcd_value" "${array[i]}"
		((gcd_value=$?))
	done
	echo "$gcd_value"
else
	exit
fi
