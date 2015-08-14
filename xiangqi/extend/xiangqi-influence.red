Red [
	"Computing the influence on the board of Xiangqi aka Chinese Chess"
	filename: %xiangqi-influence.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "09-Feb-2015"
]
; Needs from moves
red-palace:   [31 32 33 41 42 43 51 52 53]
black-palace: [38 39 40 48 49 50 58 59 60]

get-field-king: function [
	"Find the red(0) or black(1) king on this board"
	in-board [block!]
	color [integer!]
	return: [integer!]
	/local field [integer!]
][
	field: 0
	either color = RED [ ; find the red king in his palace
		foreach i red-palace [
			if 128 = in-board/:i [
				field: i
				return field
			]
		]
	][ ; find the black king in his palace
		foreach i black-palace [
			if 129 = in-board/:i [
				field: i
				return field
			]
		]
	]
	field
]
piece-color: function [
	piece-value [integer!]
	return: [integer!]
][
	piece-value and 1
]
; end needs from moves
;*******************
; influence routines
;*******************
; influence makes clear where the pieces can go, what pieces and fields are attacked, which pieces and fields are protected and how many times.
; a king can only move to a place that is not under attack. Because the kings may not see each other it is tempting to have this influence here too,
; but because the king cannot move out of his own palace this would give a wrong balance in exchanging series,
; so this restriction will be tested independent in king-sees-king.
; To have a valid view, also pins need to be taken into account. a pinned piece may not be able to defend another piece or field.
; influence table and pin information must be analysed together.
;*******************
influence-board: copy empty-board

init-influence: does [
	influence-board: copy empty-board
]

influence-list: copy []

influence-board-red: copy empty-board
influence-board-black: copy empty-board

init-influence-list: does [
	repeat i 90 [
		append influence-list reduce [i copy []]
	]
	influence-board-red: copy empty-board
	influence-board-black: copy empty-board
]

get-total-influence-value: function [
	return: [integer!]
	/local total-influence-value  [integer!]
][
	total-influence-value: 0
	repeat i 90 [
		total-influence-value: total-influence-value + influence-board/:i
	]
	total-influence-value
]

add-influence: func [
	"Add an influence point to the influence board at the given field"
	field [integer!]
	piece-value [integer!]
	from-field-value [integer!]
	influence-list? [logic!]
	/local pieces [block!]
][
	influence-board/:field: influence-board/:field + 1
	if influence-list? [
		pieces: select influence-list field
		append/only pieces reduce [piece-value  from-field-value]
	]
]

;**********************************
; Pin routine done within influence
;**********************************
DIRECTION-UP:     1
DIRECTION-DOWN:   negate 1
DIRECTION-LEFT:   negate 10
DIRECTION-RIGHT:  10

pin-list: copy []

init-pin-list: does [
	pin-list: copy []
]

add-pin: function [
	pin-info [block!]
][
	append/only pin-list pin-info
]

;***********************************
; make the influence board per color
;***********************************
influence-of-color: function [
	"Compute the influence of the (enemy) pieces"
	in-board [block!]
	color [integer!]
	influence-list? [logic!]
	return: [integer!]
	/local i [integer!] j [integer!] k [integer!]
	piece-value [integer!] piece-moves [block!] over-field [integer!] to-field [integer!]
	line [integer!] row [integer!] field-enemy-king [integer!] line-king [integer!] row-king [integer!]
	loaded [logic!] done [logic!] pin-direction [integer!] possible-pins [block!] pin-string [string!]
][
	init-influence
	field-enemy-king: get-field-king in-board 1 - color
	line-king: ((field-enemy-king - 1) / 10)       ; 0 to 8 only to compare same line
	row-king:  remainder (field-enemy-king - 1) 10 ; not + 1 for only to compare for pin same row

	repeat i 90 [
		piece-value: in-board/:i
		if all [0 < piece-value
				color = piece-color piece-value ][
			multi-switch piece-value [
				2 [ ; red-pawn, done separately from the black one because they move opposite way
					if 10 > remainder i 10 [
						j: i + 1
						add-influence j piece-value i influence-list?
					]
					if 5 < remainder i 10 [
						if i > 10 [	j: i - 10
									add-influence j piece-value i influence-list?]
						if i < 81 [	j: i + 10
									add-influence j piece-value i influence-list?]
					]
				]
				3 [ ; black-pawn, done separately from the red one because they move opposite way
					if 1 < remainder i 10 [
						j: i - 1
						add-influence j piece-value i influence-list?
					]
					if 6 > remainder i 10 [
						if i > 10 [	j: i - 10
									add-influence j piece-value i influence-list?]
						if i < 81 [	j: i + 10
									add-influence j piece-value i influence-list?]
					]
				]

				4 5 [ ; canon, can also (double) pin pieces
					; pin can be if on same line or row as enemy king and the test is only needed in this line
					; canon can jump over own and enemy pieces
					line: (i - 1) / 10        ; need for pin and same line for not extending your move onto prev/next line
					row: remainder (i - 1) 10 ; only to compare with row-king for pin
					pin-direction: 0
					if line-king = line [
						either row < row-king [
							pin-direction: DIRECTION-UP
						][
							pin-direction: DIRECTION-DOWN
						]
					]	
					if row-king = row [
						either line < line-king [
							pin-direction: DIRECTION-RIGHT					
						][
							pin-direction: DIRECTION-LEFT
						]
					]
					; left
					loaded: done: false
					j: i - 10
					while [all [j > 0
								not done]][
						if loaded [
							add-influence j piece-value i influence-list?
							if 0 < in-board/:j [
								done: true
							]
						]
						if 0 < in-board/:j [loaded: true]
						j: j - 10
					]
					; right
					loaded: done: false
					j: i + 10
					while [all [j < 91
								not done]][
						if loaded [
							add-influence j piece-value i influence-list?
							if 0 < in-board/:j [
								done: true
							]
						]
						if 0 < in-board/:j [loaded: true]
						j: j + 10
					]
					; up
					loaded: done: false
					j: i + 1
					line: (i - 1) / 10
					while [all [j < 91
								not done
								line = ((j - 1) / 10)]][
						if loaded [
							add-influence j piece-value i influence-list?
							if 0 < in-board/:j [
								done: true
							]
						]
						if 0 < in-board/:j [loaded: true]
						j: j + 1
					]
					; down
					loaded: done: false
					j: i - 1
					line: (i - 1) / 10
					while [all [j > 0
								not done
								line = ((j - 1) / 10)]][
						if loaded [
							add-influence j piece-value i influence-list?
							if 0 < in-board/:j [
								done: true
							]
						]
						if 0 < in-board/:j [loaded: true]
						j: j - 1
					]
					; If possible then check the pins for canon
					if pin-direction <> 0 [
						possible-pins: copy []
						pin-string: copy ""
						j: i + pin-direction
						while [j <> field-enemy-king][
							if 0 < in-board/:j [
								either color = (BLACK and in-board/:j) [
									append pin-string "o"
								][
									append pin-string "x"
									append/only possible-pins reduce [in-board/:j j piece-value i]
								]
							]
							j: j + pin-direction
						]
						; canon an enemy piece is pinned if exactly two pieces are between canon and king
						if all [2 = length? pin-string
							    0 < length? possible-pins][
							foreach pin possible-pins [
								add-pin pin
							]
						]						
					]
				]

				8 9 [ ; chariot, rook, can also pin pieces
					; pin can be if on same line or row as enemy king and the test is only needed in this line
					; rook cannot jump over own pieces like canon
					line: (i - 1) / 10        ; need for pin and same line for not extending your move onto prev/next line
					row: remainder (i - 1) 10 ; only to compare with row-king for pin
					pin-direction: 0
					if line-king = line [
						either row < row-king [
							pin-direction: DIRECTION-UP
						][
							pin-direction: DIRECTION-DOWN
						]
					]	
					if row-king = row [
						either line < line-king [
							pin-direction: DIRECTION-RIGHT					
						][
							pin-direction: DIRECTION-LEFT
						]
					]
					; left
					j: i - 10
					while [j > 0][
						add-influence j piece-value i influence-list?
						if 0 < in-board/:j [
							if piece-value <> in-board/:j [	; continue through own chariot, else stop
								j: 0
							]
						]
						j: j - 10
					]
					; right
					j: i + 10
					while [j < 91][
						add-influence j piece-value i influence-list?
						if 0 < in-board/:j [
							if piece-value <> in-board/:j [	; continue through own chariot, else stop
								j: 91
							]
						]
						j: j + 10
					]
					; up
					j: i + 1
					;line: (i - 1) / 10
					while [all [line = ((j - 1) / 10)
								 j < 91       		]][
						add-influence j piece-value i influence-list?
						if 0 < in-board/:j [
							if piece-value <> in-board/:j [	; continue through own chariot, else stop
								j: j + 10
							]
						]
						j: j + 1
					]
					; down
					j: i - 1
					;line: (i - 1) / 10
					while [all [line = ((j - 1) / 10)
								j > 0				]][
						add-influence j piece-value i influence-list?
						if 0 < in-board/:j [
							if piece-value <> in-board/:j [	; continue through own chariot, else stop
								j: j - 10
							]
						]
						j: j - 1
					]
					; If possible then check the pins for chariot, rook
					if pin-direction <> 0 [
						; the special check if we stay on the same line is not needed her because we already know
						possible-pins: copy []
						pin-string: copy ""
						j: i + pin-direction
						while [j <> field-enemy-king][
							if 0 < in-board/:j [
								either color = (BLACK and in-board/:j) [
									append pin-string "o"
								][
									append pin-string "x"
									append/only possible-pins reduce [in-board/:j j piece-value i]
								]
							]
							j: j + pin-direction
						]
						;rook if own pieces present in pin-string, no pins else if only 1 x then add pin
						if pin-string = "x" [
							add-pin possible-pins/1
						]
					]
				]

				16 17 [ ; knight, can also pin pieces(!)
					line: 1 + ((i - 1) / 10)
					row: 1 + remainder (i - 1) 10
					; left -10 (-10 +/- 1)
					if line > 2 [ ; else too close to the border to go that way
						j: i - 10
						either 0 = in-board/:j [ ; not blocked
							if row > 1 [
								j: i - 21
								add-influence j piece-value i influence-list?
							]
							if row < 10 [
								j: i - 19
								add-influence j piece-value i influence-list?
							]
						][ ; check if the knight pins the blocking piece
							if any [i - 21 = field-enemy-king
									i - 19 = field-enemy-king][
								add-pin reduce [in-board/:j j piece-value i]
							]
						]
					]
					; right
					if line < 8 [ ; else too close to the border to go that way
						j: i + 10
						either 0 = in-board/:j [ ; not blocked
							if row > 1 [
								j: i + 19
								add-influence j piece-value i influence-list?
							]
							if row < 10 [
								j: i + 21
								add-influence j piece-value i influence-list?
							]
						][ ; check if the knight pins the blocking piece
							if any [i + 21 = field-enemy-king
									i + 19 = field-enemy-king][
								add-pin reduce [in-board/:j j piece-value i]
							]
						]
					]
					; up
					if row < 9 [
						j: i + 1
						either 0 = in-board/:j [ ; not blocked
							if line > 1 [
								j: i - 8
								add-influence j piece-value i influence-list?
							]
							if line < 9 [
								j: i + 12
								add-influence j piece-value i influence-list?
							]
						][ ; check if the knight pins the blocking piece
							if any [i - 8  = field-enemy-king
									i + 12 = field-enemy-king][
								add-pin reduce [in-board/:j j piece-value i]
							]
						]
					]
					; down
					if row > 2 [
						j: i - 1
						either 0 = in-board/:j [ ; not blocked
							if line > 1 [
								j: i - 12
								add-influence j piece-value i influence-list?
							]
							if line < 9 [
								j: i + 8
								add-influence j piece-value i influence-list?
							]
						][ ; check if the knight pins the blocking piece
							if any [i - 12 = field-enemy-king
									i + 8  = field-enemy-king][
								add-pin reduce [in-board/:j j piece-value i]
							]
						]
					]
				]

				32 33 [ ; elephant, has no direct influence on giving check, but general influence also considered here
					if element-in-collection i elephant-moves [
						piece-moves: select elephant-moves i
						foreach move piece-moves [
							over-field: move/1
							to-field: move/2
							if 0 = in-board/:over-field [
								 add-influence to-field piece-value i influence-list?
							]
						]
					]
				]

				64 65 [ ; advisor, just add the influence
					if element-in-collection i advisor-moves [
						piece-moves: select advisor-moves i
						foreach move piece-moves [
							add-influence move piece-value i influence-list?
						]
					]
				]

				128 129 [ ; king, just add the influence
					if element-in-collection i king-moves [
						piece-moves: select king-moves i
						foreach move piece-moves [
							add-influence move piece-value i influence-list?
	]   ]   ]   ]   ]   ]

	;return the total influence computed
	get-total-influence-value
]

analyse-influence: function [
	"Make influence boards and a list of pieces that can go to the fields"
	board [block!]
][
	init-influence-list
	influence-of-color board 1 true
	influence-board-red: copy influence-board
	influence-of-color board 0 true
	influence-board-black: copy influence-board
	; remember that the pieces still may be pinned and
	; are not actually defending or attacking other positions!
	; also moving one piece may pin the next
]
