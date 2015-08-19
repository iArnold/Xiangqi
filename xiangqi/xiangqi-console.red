Red [
	"Console program for Xiangqi"
	filename: %xiangqi-console.red
	author:   "Arnold van Hofwegen"
	version:  0.2.1
	date:     "17-Aug-2015"
]

; Import function 'ask and time for initializing random numbers
#include %../bind/C-library/ANSI.red

; Seed the random numbers, use the seconds from now/precise from the binding
; unfortunately not more precise yet but this is more than enough for our use.
seconds: remainder now/precise 65536
random/seed seconds

; Import the xiangqi programs

; Common definitions
#include %xiangqi-common.red

; Move generation
#include %xiangqi-move-common.red
#include %xiangqi-moves.red

; Position evaluation
#include %xiangqi-evaluate.red

; Hash calculations 
#include %xiangqi-hash.red

; Opening book information
#include %xiangqi-open.red

; Notation conversion and conversion between board and screen values of fields
#include %xiangqi-convertions.red

; Calculate the best move using a PVS like algorithm
#include %xiangqi-best-move.red

; Initialize variables for a new game here
init-xiangqi-display-set/standard

; turn on/off opening book
in-opening-book: true

; Board, side to play, moves
; First make items in 'global' scope
player-to-move: RED
move-number: 1
autoplay: true
move-history: copy []
computer-has: BLACK
search-depth: 2 ; MAX-DEPTH - 1
console-board: copy start-board
inactivity-counter: 0
show-board?: true
show-moves?: true

; And set them in the init function
start-new-game: func [
][
	player-to-move: RED
	move-number: 1
	autoplay: true
	move-history: copy []
	computer-has: BLACK
	answer: ask "Do you want to play with Red/White, computer has Blue/Black? (Y/N)"
	either #"N" = first uppercase answer [
		computer-has: RED
		print "You have Blue/Black (Lowercase pieces) and the computer has White/Red."
	][
		print "You have White/Red (Uppercase pieces) and the computer has Blue/Black."
	]
	search-depth: 2 ; MAX-DEPTH - 1
	console-board: copy start-board
	inactivity-counter: 0
 	show-board?: true
	show-moves?: true
]

start-new-game

;******************
; Process the input
;******************
;process-input: func [
CMD-AGAIN: 0
CMD-QUIT: 1
CMD-BOARD: 2
CMD-MOVES: 3
CMD-HELP: 4
CMD-UNDO: 5
CMD-AUTO: 6
CMD-COMPUTE: 7
CMD-NEW: 8
CMD-LEVEL: 9
CMD-PLAY: 10
CMD-SWAP: 11
CMD-HISTORY-RECORD: 12 ; "R" recorded

answer-to-command: function [
	answer [string!]
	return: [string!]
][ 
	;print ["answer-input is " answer]
	answer: uppercase answer
	if any [answer = "Q"
			answer = "QUIT"][return CMD-QUIT]
	if any [answer = "B"
			answer = "BOARD"][return CMD-BOARD]
	if any [answer = "H"
			answer = "HELP"][return CMD-HELP]
	if any [answer = "M"
			answer = "MOVES"][return CMD-MOVES]
	if any [answer = "U"
			answer = "UNDO"][return CMD-UNDO]
	if any [answer = "A"
			answer = "AUTO"][return CMD-AUTO]
	if any [answer = "C"
			answer = "COMPUTE"][return CMD-COMPUTE] ; Play
	if any [ #"L" = first answer
			answer = "LEVEL"][return CMD-LEVEL]
	if any [answer = "N"
			answer = "NEW"][return CMD-NEW]
	if any [answer = "R"
			answer = "RECORD"
			answer = "HIST"
			answer = "HISTORY"][return CMD-HISTORY-RECORD]
	return CMD-AGAIN
]

console-help-string: {
Available commands:
	choose the move number to select your move from the shown moves
	H HELP		- This help message
	B BOARD		- Show the board
	M MOVES		- Show the available moves
	N NEW		- Start a new game
	L LEVEL		- Change the search depth or program level
	C COMPUTE	- Let the program compute a best move
	Q QUIT		- Exit the program
}

check-inactivity: func [
][
	inactivity-counter: inactivity-counter + 1
	if 4 < inactivity-counter [
		print "Use H or HELP for help, Q to stop/quit/end the program"
		inactivity-counter: 0
	]
]

;*********************
; Main loop until quit
;*********************
ready?: false
show-board?: true
show-moves?: true

until [
	move-list: make-move-list console-board player-to-move
	either 0 = length? move-list [
		print ["No more legal moves possible for" either RED = player-to-move ["Red"]["Black"]]
		print ["It seems that" either player-to-move = computer-has ["you"]["I"] "have won this game!"]
		raw-answer: ask "Play a new game? (Y/N)"
		answer: load raw-answer
		if string! = type? answer [
			answer: uppercase first answer
		]
		either #"Y" = answer [
			start-new-game
		][
			ready?: true
		]
	][
		if show-board? [display-board console-board]
		if show-moves? [
			;move-list: make-move-list console-board player-to-move
	
 			number-possible-moves: length? move-list
 			print ["number of possible moves" number-possible-moves]
 			print compose-console-move-list console-board move-list
 		]
 		show-board?: false
		show-moves?: false

		either computer-has = player-to-move [
			; compute best move using IDS
			print ["Computing move for " either 0 = player-to-move ["White/Red "]["Blue/Black"] "at level " search-depth]
			computed-move: iterative-deepening-search console-board player-to-move search-depth
			player-to-move: 1 - player-to-move
			either 2 = length? computed-move [ ; The move comes from a (opening) book.
				i: computed-move/1
				j: computed-move/2
			][
				i: computed-move/2
				j: computed-move/3
			]
			print ["I played the move" notation-to-chinese console-board i j ]
			; play the computed move
			piece-value: console-board/:i
			console-board/:i: 0
			captured: console-board/:j
			console-board/:j: piece-value

			show-board?: true
			show-moves?: true
		][
			raw-answer: ask "Your move please (H for Help, Q to quit) >"
			answer: load raw-answer
			either integer! = type? answer [
				maximum-input-move: length? move-list
				either all [
					0 < answer
					maximum-input-move >= answer][
					player-move: move-list/:answer
					; play the given move
					i: player-move/2
					j: player-move/3
					piece-value: console-board/:i
					console-board/:i: 0
					captured: console-board/:j
					console-board/:j: piece-value

					show-board?: true
					player-to-move: 1 - player-to-move
				][
					print "I did not understand your choice"
	 				check-inactivity
				]
			][
			 	answer: uppercase raw-answer
			 	if string! = type? raw-answer[
		 			raw-answer: uppercase raw-answer
		 		]
		 		command-or-move: answer-to-command raw-answer
		 		switch command-or-move [
		 			0 [ ; CMD-AGAIN, nothing done perhaps quit after 5 consecutive occurences?
	 					check-inactivity
		 			]
			 		1 [ ; CMD-QUIT
			 			print "Quitting now! Bye!"
			 			ready?: true
			 		]
			 		2 [ ; CMD-BOARD
			 			show-board?: true
			 		]
			 		3 [ ; CMD-MOVES
			 			show-moves?: true
			 		]
			 		4 [ ; CMD-HELP
			 			print console-help-string
			 		]
					;CMD-UNDO: 5
					;CMD-AUTO: 6
					7 [ ;CMD-COMPUTE: 7 ; computes best move
						computer-has: 1 - computer-has ; change colors
					]
					8 [ ;CMD-NEW: 8
						raw-answer: ask "This starts a new game. Are you sure (Y/N)"
						answer: load raw-answer
						if string! = type? raw-answer [
							answer: uppercase first raw-answer
						]
						if #"Y" = answer [
							start-new-game
						]
					]
					9 [ ;CMD-LEVEL: 9
						print ["Current searchdepth/playlevel is: " search-depth]
						raw-answer: ask "Give new search depth > "
						answer: load raw-answer
						print type? answer
						either all [integer! = type? answer
								0 > answer 
								MAX-DEPTH <= answer][
							init-search-depth answer
							print ["Search depth/level now set to" search-depth]
						][
							print "Answer not understood. Search depth not changed."
						]
					]
					;CMD-PLAY: 10
					;CMD-SWAP: 11	 		
			 		;CMD-HISTORY-RECORD: 12
			 	]
			]
		]
	]
	
	ready?	
]
