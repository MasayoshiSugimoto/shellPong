#!/bin/sh

#User inputs are synchronized on a file. This script must run before pong.sh

rm -f userInputP2
while [ true ]
do
	x=''
	read -n1 x
	echo $x >> userInputP2
done
