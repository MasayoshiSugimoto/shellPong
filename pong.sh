#!/bin/sh

#Get screen coordinates
screenXMax=$(tput cols)
screenYMax=$(expr $(tput lines) - 1)

#Ball coordinates
ballX=$(expr $screenXMax / 2) #Unit is character
ballY=$(expr $screenYMax / 2) #Unit is character
ballSpeed=1 #Unit is character per refresh
ballDirectionX=1 #Unit is character
ballDirectionY=1 #Unit is character

paddleLength=4
paddleP1Y=$(( $(( $screenYMax / 2 )) + $(( $paddleLength / 2 ))  ))
paddleP2Y=$(( $(( $screenYMax / 2 )) + $(( $paddleLength / 2 ))  ))
paddleSpeed=2 #Pixel

#Game loop
while [ true ]
do

	#Get user input
	#We synchronize on a file. Another process prints the user inputs to a file.
	#We add an empty line to make sure we do not read the input twice.
	userInputP1=$(tail -n1 userInputP1)
	echo >> userInputP1

	userInputP2=$(tail -n1 userInputP2)
	echo >> userInputP2

	#Update the player1's paddle
	if [ -n "$(echo $userInputP1 | grep w)" ] #Player1's paddle go up when w is pressed
	then
		paddleP1Y=$(( $paddleP1Y - $paddleSpeed ))
	elif [ "$(echo $userInputP1 | grep s)" ] #Player1's paddle go down when s is pressed
	then
		paddleP1Y=$(( $paddleP1Y + $paddleSpeed ))
	fi	

	#Update the player2's paddle
	if [ -n "$(echo $userInputP2 | grep i)" ] #Player2's paddle go up when i is pressed
	then
		paddleP2Y=$(( $paddleP2Y - $paddleSpeed ))
	elif [ "$(echo $userInputP2 | grep k)" ] #Player2's paddle go down when k is pressed
	then
		paddleP2Y=$(( $paddleP2Y + $paddleSpeed ))
	fi	

	#Update the ball coordinates
	ballX=$(expr $ballX + $ballDirectionX)
	ballY=$(expr $ballY + $ballDirectionY)

	#Reverse the direction on collision
	if [ $ballX -gt $screenXMax ] || [ $ballX -lt 1 ]
	then
		ballDirectionX=$(( $ballDirectionX * -1 ))
	fi
	if [ $ballY -gt $screenYMax ] || [ $ballY -lt 1 ]
	then
		ballDirectionY=$(( $ballDirectionY * -1 ))
	fi

	#Reverse the direction on collision with a paddle
	if [ $ballX -eq 1 ] && [ $ballY -gt $paddleP1Y ] && [ $ballY -le $(( $paddleP1Y + $paddleLength )) ]
	then
		ballX=2
		ballDirectionX=$(( $ballDirectionX * -1 ))
	fi
	if [ $ballX -eq $screenXMax ] && [ $ballY -gt $paddleP2Y ] && [ $ballY -le $(( $paddleP2Y + $paddleLength )) ]
	then
		ballX=$(( $screenXMax - 1 ))
		ballDirectionX=$(( $ballDirectionX * -1 ))
	fi

	#Keep the ball inside the screen
	if [ $ballX -gt $screenXMax ]
	then
		ballX=$screenXMax
	elif [ $ballX -lt 1 ]
	then
		ballX=1
	fi

	if [ $ballY -gt $screenYMax ]
	then
		ballY=$screenYMax
	elif [ $ballY -lt 1 ]
	then
		ballY=1
	fi

	#Print the screen
	screenBuffer='' #reset the screen
	for y in $(seq $screenYMax)
	do
		for x in $(seq $screenXMax)
		do
			currentPixel=' '

			#Print the ball
			if [ $ballX -eq $x ] && [ $ballY -eq $y ]
			then
				currentPixel='0'
			fi

			#Print player1's paddle
			if [ $x -eq 1 ] && [ $y -ge $paddleP1Y ] && [ $y -le $(( $paddleP1Y + $paddleLength )) ]
			then
				currentPixel='|'
			fi

			#Print player2's paddle
			if [ $x -eq $screenXMax ] && [ $y -ge $paddleP2Y ] && [ $y -le $(( $paddleP2Y + $paddleLength )) ]
			then
				currentPixel='|'
			fi

			#Add the current character to the screen buffer
			screenBuffer="$screenBuffer$currentPixel"

		done
		screenBuffer="$screenBuffer"$'\n' #Go to the next line
	done
	printf '%s' "$screenBuffer"

done
