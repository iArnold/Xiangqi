Red [
	"Move generation for the game of xiangqi aka Chinese Chess"
	filename: %xiangqi-moves.red
	author:   "Arnold van Hofwegen"
	version:  0.3
	date:     "30-Mar-2015"
	needs:	  "xiangqi-move-common.red"
]

;******************************
; Generating the moves routines
;******************************
;*************************************************
; King check? and validation of the move functions
;*************************************************
king-sees-king: function [
	in-board [block!]
	field1 [integer!]
	field2 [integer!]
	return: [logic!]
	/local i [integer!] line-king-1 [integer!] line-king-2 [integer!] field-end [integer!]
][
	line-king-1: 1 + ((field1 - 1) / 10)
	line-king-2: 1 + ((field2 - 1) / 10)

	if line-king-1 = line-king-2 [
		either field1 < field2 [
			field-end: field2
			i: field1 + 1
		][
			field-end: field1
			i: field2 + 1
		]
		while [i < field-end][
			if 0 < in-board/:i [ return false ]
			i: i + 1
		]
		return true
	]
	false
]

king-check?: function [
	in-board [block!]
	color    [integer!]
	return: [integer!]
	/fast
	/local own-king-pos [integer!]
	other-king-pos [integer!]
	kings-row [integer!]
	field [integer!]
	field-value [integer!]
	times-check [integer!]
	steps [block!]
	down-limit [integer!]
	up-limit [integer!]
	can-find-check [logic!]
][
	times-check: 0
	own-king-pos: get-field-king in-board color
	other-king-pos: get-field-king in-board 1 - color

	; check for check by pawn
	field: own-king-pos + (power -1 color)
	field-value: in-board/:field
	if all [PAWN = (PAWN and field-value)
			BLACK = (color xor (BLACK and field-value)) ][either fast [return 1][times-check: times-check + 1]]
	field: own-king-pos + 10
	field-value: in-board/:field
	if all [PAWN = (PAWN and field-value)
			BLACK = (color xor (BLACK and field-value)) ][either fast [return 1][times-check: times-check + 1]]
	field: own-king-pos - 10
	field-value: in-board/:field
	if all [PAWN = (PAWN and field-value)
			BLACK = (color xor (BLACK and field-value)) ][either fast [return 1][times-check: times-check + 1]]

	; check for check by horse
	field: own-king-pos + (power -1 color) + 10
	field-value: in-board/:field
	if 0 = field-value [
		field: field + 10
		field-value: in-board/:field
		if all [KNIGHT = (KNIGHT and field-value)
				BLACK = (color xor (BLACK and field-value)) ][either fast [return 1][times-check: times-check + 1]]
		field: field - 10 + (power -1 color)
		field-value: in-board/:field
		if all [KNIGHT = (KNIGHT and field-value)
				BLACK = (color xor (BLACK and field-value)) ][either fast [return 1][times-check: times-check + 1]]
	]
	field: own-king-pos + (power -1 color) - 10
	field-value: in-board/:field
	if 0 = field-value [
		field: field - 10
		field-value: in-board/:field
		if all [KNIGHT = (KNIGHT and field-value)
				BLACK = (color xor (BLACK and field-value)) ][either fast [return 1][times-check: times-check + 1]]
		field: field + 10 + (power -1 color)
		field-value: in-board/:field
		if all [KNIGHT = (KNIGHT and field-value)
				BLACK = (color xor (BLACK and field-value)) ][either fast [return 1][times-check: times-check + 1]]
	]
	kings-row: multi-switch own-king-pos [
		31 41 51 40 50 60 [1]
		32 42 52 39 49 59 [2]
		33 43 53 38 48 58 [3]
	]
	if 1 < kings-row [
		field: own-king-pos - (power -1 color) + 10
		if 0 = field-value [
			field: field + 10
			field-value: in-board/:field
			if all [KNIGHT = (KNIGHT and field-value)
					BLACK = (color xor (BLACK and field-value)) ][either fast [return 1][times-check: times-check + 1]]
			if 2 < kings-row [
				field: field - 10 - (power -1 color)
				field-value: in-board/:field
				if all [KNIGHT = (KNIGHT and field-value)
						BLACK = (color xor (BLACK and field-value)) ][either fast [return 1][times-check: times-check + 1]]
			]
		]
		field: own-king-pos - (power -1 color) - 10
		if 0 = field-value [
			field: field - 10
			field-value: in-board/:field
			if all [KNIGHT = (KNIGHT and field-value)
					BLACK = (color xor (BLACK and field-value)) ][either fast [return 1][times-check: times-check + 1]]
			if 2 < kings-row [
				field: field + 10 - (power -1 color)
				field-value: in-board/:field
				if all [KNIGHT = (KNIGHT and field-value)
						BLACK = (color xor (BLACK and field-value)) ][either fast [return 1][times-check: times-check + 1]]
			]
		]
	]
	
	; check for check by rook
	; to the left, to the right, down and up
	steps: [-10 10 -1 1]
	foreach step steps [
		either element-in-collection step [-1 1] [ ; was a multi-switch with default not nesting now
				multi-switch own-king-pos [
					31 32 33 38 39 40 [
						down-limit: 30
						up-limit: 41
					]
					41 42 43 48 49 50 [
						down-limit: 40
						up-limit: 51
					]
					51 52 53 58 59 60 [
						down-limit: 50
						up-limit: 61
					]
				]
		][
			down-limit: 0
			up-limit: 91
		]
		field: own-king-pos + step

		can-find-check: true
		while [	all [	field > down-limit
						field < up-limit  
						can-find-check		]][
			field-value: in-board/:field
			if 0 < field-value [
				either all [ROOK = (ROOK and field-value)
						BLACK = (color xor (BLACK and field-value)) ][
					either fast [return 1][times-check: times-check + 1]
				][
					; other type or own color piece, so no check from a rook on this side
					can-find-check: false
				]
			]
			field: field + step
		]
	]

	; check for check by canon
	; to the left, to the right, down and up
	steps: [-10 10 -1 1]
	foreach step steps [
		either element-in-collection step [-1 1] [ ; was a multi-switch with default not nesting now
				multi-switch own-king-pos [
					31 32 33 38 39 40 [
						down-limit: 30
						up-limit: 41
					]
					41 42 43 48 49 50 [
						down-limit: 40
						up-limit: 51
					]
					51 52 53 58 59 60 [
						down-limit: 50
						up-limit: 61
					]
				]
		][
			down-limit: 0
			up-limit: 91
		]
		field: own-king-pos + step
		number-pieces: 0
		can-find-check: true
		while [	all [	field > down-limit
						field < up-limit 
						can-find-check		]][
			field-value: in-board/:field
			if 0 < field-value [
				either all [CANON = (CANON and field-value)
						BLACK = (color xor (BLACK and field-value)) ][
					if 1 = number-pieces [either fast [return 1][times-check: times-check + 1]]
				][
					if 2 = number-pieces [can-find-check: false]
				]
				number-pieces: number-pieces + 1
			]
			field: field + step
		]
	]

	; other king
	if king-sees-king in-board own-king-pos other-king-pos [times-check: times-check + 1]

	return times-check
]

valid-move?: function [
	"Check if a generated move is valid, not putting own king in chess position"
	in-board [block!]
	color [integer!]
	return: [logic!]
][
	either 0 < king-check?/fast in-board color [return false][return true]
]

;*************************************
; Test and add valid moves to the list
;*************************************
; Declaration of extra variables so this information does not have to be passed 31 times
tam-capture: false
tam-check: false
tam-c-or-c: false

; Add a calculated hash value to the move, skip the addition of move-values
tam-calculate-hash: false
tam-skip-values: false

generator-moves-found: false

set-generator-moves-found: func [
	set-value [logic!]
][
	generator-moves-found: set-value
]

generator-found-moves?: func [
	return: [logic!]
][
	generator-moves-found
]

hash-block-position: copy []

set-hash: func [
	in-board [block!]
][
	hash-block-position: calculate-hash in-board
]

get-hash: func [
	return: [block!]
][
	hash-block-position
]

test-add-move: func [
	"Test the move to be legit and than add the move to the movelist"
	in-board [block!]
	color [integer!]
	m [integer!]
	n [integer!]
	movelist [block!]
	/local piece-value [integer!] valid-move [logic!] giving-check [logic!]
	board-change-value [integer!] this-move [block!]
	captured [integer!] 
	new-board-hash [block!]
][
	; Perform the move
	piece-value: in-board/:m
	in-board/:m: 0
	captured: in-board/:n
	in-board/:n: piece-value

	; test the move
	giving-check: false
	this-move: copy []
	; this check is to assure the own King is not put into a checked position
	valid-move: valid-move? in-board color
	if valid-move [
		; Check if our move is giving check to the enemy King
		giving-check: 0 < king-check?/fast in-board (1 - color)
		if any [	all [	not tam-capture
							not tam-check    ]
					all [	tam-check
							giving-check ]
					all [	tam-capture
							0 < captured ]
					all [	tam-c-or-c	; check or capture		
							any [	0 < captured
									giving-check ]
					]
			][
			this-move: reduce [piece-value m n captured giving-check]
			if tam-calculate-hash [
				new-board-hash-value: calculate-new-hash-from-move in-board get-hash m n
				append/only this-move new-board-hash-value
			]
			if not tam-skip-values [
				board-change-value: evaluate-move-value reduce [piece-value m n captured]
				append this-move board-change-value
			]
		]
		; Also note a valid move exists even if it is not a check or capture
		set-generator-moves-found true
	]
	if 0 < length? this-move [
		movelist: append/only movelist this-move
	]

	; undo the move
	in-board/:m: piece-value
	in-board/:n: captured
]

;****************************
; Main routine make-move-list
;****************************
make-move-list: func [
	in-board [block!]
	color [integer!]
	return: [block!]
	/capture
	/check
	/c-or-c
	/anymoves?
	/hash
	/skip-values
	/local j [integer!] giving-check [logic!]
	over-field [integer!] to-field [integer!] 
	line [integer!] row [integer!] 
	loaded [logic!] done [logic!] 
	movelist [block!] 
][
	movelist: copy []
	set-generator-moves-found false
	
	; We need to initialize these 'global' values so we do not need to pass them over and over again 
	; (31 times in coding and the total number of moves times per call)
	tam-capture: capture
	tam-check: check
	tam-c-or-c: c-or-c
	
	tam-calculate-hash: hash
	tam-skip-values: skip-values
	
	if hash [
		set-hash in-board
	]
	
	repeat i 90 [
		piece-value: in-board/:i
		if all [ 0 < piece-value
				 color = piece-color piece-value ][
			multi-switch piece-value [
				2 [ ; red-pawn, done separately from the black one because they move opposite way
					if 10 > remainder i 10 [
						j: i + 1
						if any [ 0 = in-board/:j
								color <> piece-color in-board/:j ][
							test-add-move in-board color i j movelist					
						]
					]
					if 5 < remainder i 10 [
						if i > 10 [	
							j: i - 10
							if any [ 0 = in-board/:j
									color <> piece-color in-board/:j ][
								test-add-move in-board color i j movelist
							]
						]
						if i < 81 [	
							j: i + 10
							if any [ 0 = in-board/:j
									color <> piece-color in-board/:j ][
								test-add-move in-board color i j movelist
							]
				]	]	]

				3 [ ; black-pawn, done separately from the red one because they move opposite way
					if 1 < remainder i 10 [
						j: i - 1
						if any [ 0 = in-board/:j
								color <> piece-color in-board/:j ][
							test-add-move in-board color i j movelist
						]
					]
					if 6 > remainder i 10 [
						if i > 10 [	
							j: i - 10
							if any [ 0 = in-board/:j
									color <> piece-color in-board/:j ][
								test-add-move in-board color i j movelist
							]
						]
						if i < 81 [	
							j: i + 10
							if any [ 0 = in-board/:j
									color <> piece-color in-board/:j ][
								test-add-move in-board color i j movelist
				]	]	]	]

				4 5 [ ; canon
					; left
					loaded: done: false
					j: i - 10
					while [all [j > 0
								not done]][
						either loaded [
							if all [0 <> in-board/:j
									color <> piece-color in-board/:j ][
								test-add-move in-board color i j movelist
								done: true
							]
						][
							either 0 = in-board/:j [
								test-add-move in-board color i j movelist
							][
								loaded: true
							]
						]
						j: j - 10
					]						
					; right
					loaded: done: false
					j: i + 10
					while [all [j < 91
								not done]][
						either loaded [
							if all [0 <> in-board/:j
									color <> piece-color in-board/:j ][
								test-add-move in-board color i j movelist
								done: true
							]
						][
							either 0 = in-board/:j [
								test-add-move in-board color i j movelist
							][
								loaded: true
							]
						]
						j: j + 10
					]						
					; up
					loaded: done: false
					j: i + 1
					line: (i - 1) / 10
					while [all [j < 91
								not done
								line = ((j - 1) / 10)]][
						either loaded [
							if all [0 <> in-board/:j
									color <> piece-color in-board/:j ][
								test-add-move in-board color i j movelist
								done: true
							]
						][
							either 0 = in-board/:j [
								test-add-move in-board color i j movelist
							][
								loaded: true
							]
						]
						j: j + 1
					]						
					; down
					loaded: done: false
					j: i - 1
					line: (i - 1) / 10
					while [all [j > 0
								not done
								line = ((j - 1) / 10)]][
						either loaded [
							if all [0 <> in-board/:j
									color <> piece-color in-board/:j ][
								test-add-move in-board color i j movelist
								done: true
							]
						][
							either 0 = in-board/:j [
								test-add-move in-board color i j movelist
							][
								loaded: true
							]
						]
						j: j - 1
				]	]			

				8 9 [ ; chariot / rook
					; left
					j: i - 10
					while [j > 0][
						either any [0 = in-board/:j
									color <> piece-color in-board/:j ][
							test-add-move in-board color i j movelist
							if 0 <> in-board/:j [ j: 0 ]
						][
							j: 0
						]
						j: j - 10
					]
					; right
					j: i + 10
					while [j < 91][
						either any [0 = in-board/:j
									color <> piece-color in-board/:j ][
							test-add-move in-board color i j movelist
							if 0 <> in-board/:j [ j: 91 ]
						][
							j: 91
						]
						j: j + 10
					]
					; up
					j: i + 1
					line: (i - 1) / 10
					while [all [line = ((j - 1) / 10)
								 j < 91       		]][
						either 0 = in-board/:j [
							test-add-move in-board color i j movelist
						][
							if color <> piece-color in-board/:j [
								test-add-move in-board color i j movelist
							]
							j: j + 10
						]
						j: j + 1
					]
					; down
					j: i - 1
					line: (i - 1) / 10
					while [all [line = ((j - 1) / 10)
								j > 0				]][
						either 0 = in-board/:j [
							test-add-move in-board color i j movelist
						][
							if color <> piece-color in-board/:j [
								test-add-move in-board color i j movelist
							]						
							j: j - 10
						]
						j: j - 1
				]	]

				16 17 [ ; knight
					line: 1 + ((i - 1) / 10)
					row: 1 + remainder (i - 1) 10
					; left -10 (-10 +/- 1)
					if line > 2 [ ; else too close to the border to go that way
						j: i - 10
						if 0 = in-board/:j [ ; not blocked
							if row > 1 [
								j: i - 21
								if any [ 0 = in-board/:j
										color <> piece-color in-board/:j][
									test-add-move in-board color i j movelist
								]
							]
							if row < 10 [
								j: i - 19
								if any [ 0 = in-board/:j
										color <> piece-color in-board/:j][
									test-add-move in-board color i j movelist
					]	]	]	]

					; right
					if line < 8 [ ; else too close to the border to go that way
						j: i + 10
						if 0 = in-board/:j [ ; not blocked
							if row > 1 [
								j: i + 19
								if any [ 0 = in-board/:j
										color <> piece-color in-board/:j][
									test-add-move in-board color i j movelist
								]
							]
							if row < 10 [
								j: i + 21
								if any [ 0 = in-board/:j
										color <> piece-color in-board/:j][
									test-add-move in-board color i j movelist
					]	]	]	]

					; up
					if row < 9 [
						j: i + 1
						if 0 = in-board/:j [ ; not blocked
							if line > 1 [
								j: i - 8
								if any [ 0 = in-board/:j
										color <> piece-color in-board/:j][
									test-add-move in-board color i j movelist
								]
							]
							if line < 9 [
								j: i + 12
								if any [ 0 = in-board/:j
										color <> piece-color in-board/:j][
									test-add-move in-board color i j movelist
					]	]	]	]

					; down
					if row > 2 [
						j: i - 1
						if 0 = in-board/:j [ ; not blocked
							if line > 1 [
								j: i - 12
								if any [ 0 = in-board/:j
										color <> piece-color in-board/:j][
									test-add-move in-board color i j movelist
								]
							]
							if line < 9 [
								j: i + 8
								if any [ 0 = in-board/:j
										color <> piece-color in-board/:j][
									test-add-move in-board color i j movelist
				]	]	]	]	]

				32 33 [ ; elephant
					if element-in-collection i elephant-moves [
						piece-moves: select elephant-moves i
						foreach move piece-moves [
							over-field: move/1
							to-field: move/2
							if all [ 0 = in-board/:over-field
									any [ 0 = in-board/:to-field
										color <> piece-color in-board/:to-field ] ][
								test-add-move in-board color i to-field movelist
				]	]	]	]

				64 65 [ ; advisor
					if element-in-collection i advisor-moves [
						piece-moves: select advisor-moves i
						foreach move piece-moves [
							if any [ 0 = in-board/:move
									color <> piece-color in-board/:move ][
								test-add-move in-board color i move movelist
				]	]	]	]

				128 129 [ ; king
					if element-in-collection i king-moves [
						piece-moves: select king-moves i
						foreach move piece-moves [
							if any [ 0 = in-board/:move
									color <> piece-color in-board/:move ][
								test-add-move in-board color i move movelist
		]	]	]	]	]	]	
		if all [anymoves?
				generator-found-moves? ][return [true]]
	]
	if all [anymoves?
			not generator-found-moves? ][return [false]]
	
	return movelist
]