Red [
	"Position evaluation for the game of xiangqi aka Chinese Chess"
	filename: %xiangqi-evaluate.red
	author:   "Arnold van Hofwegen"
	version:  0.2.1
	date:     "28-Sep-2015"
	needs:    "%xiangqi-common.red #include via main program or testprogram"
]
;********************
; Evaluation routines
;********************
get-piece-added-value: func [
	board-piece [integer!]
	field [integer!]
	return: [integer!]
][  
	if BLACK-1 = (BLACK-1 and board-piece) [ field: 91 - field ]

	comment {	; this is how to do with directly valueing the black moves as negative
				; but probably it is better not to negate here, instead leave that up to the pvs routine.
	switch board-piece [
		  2 [ VALUE-PAWN + position-values-pawn/:field ]
		  3 [ negate ( VALUE-PAWN + position-values-pawn/:field ) ]
		  4	[ VALUE-CANON + position-values-cannon/:field ]
		  5 [ negate ( VALUE-CANON + position-values-cannon/:field ) ]
		  8	[ VALUE-CHARIOT + position-values-rook/:field ]
		  9	[ negate ( VALUE-CHARIOT + position-values-rook/:field ) ]
		 16	[ VALUE-KNIGHT + position-values-knight/:field ]
		 17	[ negate ( VALUE-KNIGHT + position-values-knight/:field ) ]
		 32	[ VALUE-ELEPHANT ]
		 33	[ negate VALUE-ELEPHANT ]
		 64	[ VALUE-ADVISOR]
		 65	[ negate VALUE-ADVISOR ]
		128	[ VALUE-KING ]
		129	[ negate VALUE-KING ]
	]
	}
	multi-switch board-piece [
		  2   3 [ VALUE-PAWN + position-values-pawn/:field ]
		  4	  5 [ VALUE-CANON + position-values-cannon/:field ]
		  8	  9 [ VALUE-CHARIOT + position-values-rook/:field ]
		 16  17 [ VALUE-KNIGHT + position-values-knight/:field ]
		 32	 33 [ VALUE-ELEPHANT ]
		 64	 65 [ VALUE-ADVISOR]
		128	129 [ VALUE-KING ]
	]
]

evaluate-board: function [
	"Simple evaluation routine for the entire board"
	board [block!]
	return: [integer!]
	/local i [integer!] moving-piece [integer!] piece-value [integer!] total-value [integer!]
][
	; for now no difference in red/black
	total-value: 0
	repeat i 90 [
		moving-piece: board/:i
		if moving-piece > 0 [
			piece-value: get-piece-added-value moving-piece i
			total-value: total-value + either even? moving-piece [piece-value][negate piece-value]
		]
	]

	total-value
]

evaluate-move-value: function [
	"Simple evaluation routine for how the move changes the board value"
	move [block!]
	return: [integer!]
	/local change-value [integer!] moving-piece [integer!] what-is-on-destination [integer!] move-value [integer!]
	from-field [integer!] destination-field [integer!]
][
	; a move is here the moving piece from field, destination field and the value of the board at the destination
	moving-piece: move/1
	from-field: move/2
	destination-field: move/3
	what-is-on-destination: move/4

	; Calculate relative value of the move
	move-value: 0
	; plus  old position destination field ( <> 0 if capture of opposite piece)
	if 0 < what-is-on-destination [
		change-value: get-piece-added-value what-is-on-destination destination-field
		move-value: move-value + change-value
	]
	; plus  new position piece
	change-value: get-piece-added-value moving-piece destination-field

	move-value: move-value + change-value
	; minus old position
	change-value: get-piece-added-value moving-piece from-field

	move-value: move-value - change-value
]
