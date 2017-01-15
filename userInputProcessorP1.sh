#!/bin/sh

#User inputs are synchronized on a file. This script must run before pong.sh

rm -f userInputP1
while [ true ]
do
	x=''
	read -n1 x
	echo $x >> userInputP1
done
