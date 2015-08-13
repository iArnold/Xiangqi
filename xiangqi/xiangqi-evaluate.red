Red [
	"Position evaluation for the game of xiangqi aka Chinese Chess"
	filename: %xiangqi-evaluate.red
	author:   "Arnold van Hofwegen"
	version:  0.2
	date:     "27-Feb-2015"
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
	if BLACK = (BLACK and board-piece) [ field: 91 - field ]

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
	/local i [integer!] move-piece [integer!] piece-value [integer!] total-value [integer!]
][
	; for now no difference in red/black
	total-value: 0
	repeat i 90 [
		move-piece: board/:i
		if move-piece > 0 [
			piece-value: get-piece-added-value move-piece i
			total-value: total-value + either even? move-piece [piece-value][negate piece-value]
		]
	]

	total-value
]

evaluate-move-value: function [
	"Simple evaluation routine for how the move changes the board value"
	move [block!]
	return: [integer!]
	/local change-value [integer!] move-piece [integer!] dest-field-value [integer!] move-value [integer!]
][
	; a move is here the moving piece from field, destination field and the value of the board at the destination
	move-piece: move/1
	from: move/2
	dest: move/3
	dest-field-value: move/4

	; Calculate relative value of the move
	move-value: 0
	; plus  old position destination field ( <> 0 if capture of opposite piece)
	if 0 < dest-field-value [
		change-value: get-piece-added-value dest-field-value dest
		move-value: move-value + change-value
	]
	; plus  new position piece
	change-value: get-piece-added-value move-piece dest

	move-value: move-value + change-value
	; minus old position
	change-value: get-piece-added-value move-piece from

	move-value: move-value - change-value
]
