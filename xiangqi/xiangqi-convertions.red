Red [
	"Conversions for GUI and notation for Xiangqi aka Chinese Chess"
	filename: %xiangqi-convertions.red
	author:   "Arnold van Hofwegen"
	version:  0.2
	date:     "12-Jun-2015"
]
;**************************************************
; Routines for helping with GUI and I/O interaction
;**************************************************

; return x, y coordinates from fieldnumber
start-position-h: start-position-v: 80 ; 80 pixels?
field-size: 100 	                 ; 100 pixels?

field-to-xy: function [
	field [integer!]
	return: [block!]
	/local line row x y
][
	if any [field < 1
			field > 90][return reduce [0 0] ]
	line: ( field - 1 ) / 10
	row: 9 - remainder (field - 1) 10
	x: start-position-h + (line * field-size)
	y: start-position-v + (row  * field-size)
	reduce [x y]
]

; return fieldnumber from x, y coordinates
xy-to-field: function [
	x [integer!]
	y [integer!]
	return: [integer!]
	/local row line field
][
	row:  y - start-position-v
	line: x - start-position-h
	;print [" x" x "y" y "line" line "row" row]
	if any [row < 0
			line < 0][return 0]
	line: 1 + (line / field-size)
	row:  10 - (row / field-size)
	;print [" x" x "y" y "line" line "row" row]
	if any [row > 10
			line > 9][return 0]
	field: (line - 1) * 10 + row
]

; When a player selects a field, and there is a piece on this field,
; the program can show the legitimate moves of this piece.
; For each field with a piece on it that has valid moves, 
; the destination fields are collected by this function
; so the destination fields can quickly be looked up and shown.
; Note: this is not the list for displaying moves in console mode
; so the user can choose a move by selecting a number
display-moves-list: function [
	move-list [block!]
	return: [block!]
	/local previous-piece [integer!] display-list [block!] dest-block [block!]
][
	previous-piece: 0
	display-list: copy []
	dest-block: copy []
	
	if 1 > length? move-list [ return copy [] ]
	foreach move move-list [
		if previous-piece <> move/2 [ ; new startfield
			if 0 < previous-piece [ ; not first to prevent an empty block at beginning
				display-list: append display-list previous-piece
				display-list: append/only display-list dest-block
			]
			; clear the destinations block
			dest-block: copy []
			previous-piece: move/2
		]
		dest-block: append dest-block move/3
	]
	; add the last info too
	display-list: append display-list move/2
	display-list: append/only display-list dest-block
]

field-to-offset: function [
	"Fieldnumber to offset for display field highlighting"
	field [integer!]
	return: [pair!]
	/local 
	p [pair!]
][
	p: 0x0
	field: field - 1
	p/2: field / 10
	p/1: 9 - (remainder field 10)
	p
]

;***************************
; Routine to print the board
;***************************
print-rows: [
[10 20 30 40 50 60 70 80 90]
 [9 19 29 39 49 59 69 79 89]
 [8 18 28 38 48 58 68 78 88]
 [7 17 27 37 47 57 67 77 87]
 [6 16 26 36 46 56 66 76 86]
 [5 15 25 35 45 55 65 75 85]
 [4 14 24 34 44 54 64 74 84]
 [3 13 23 33 43 53 63 73 83]
 [2 12 22 32 42 52 62 72 82]
 [1 11 21 31 41 51 61 71 81]
]

print-board: function [
	"Print the board using the internal representation"
	in-board [block!]
][
	print compose-output-board-internal in-board
]

compose-output-board-internal: func [
	"Offer the board using the internal representation"
	in-board [block!]
	return: [string!]
	/local
	field-value [integer!]
	row-string [string!]
	output-string [string!]
][
	; func because print-rows is a global block
	output-string: copy ""
	foreach row print-rows [
		row-string: copy ""
		foreach field row [	
			field-value: in-board/:field
			multi-switch field-value [
				128 129 [
					append row-string " "
					append row-string field-value
				]
				16 17 32 33 64 65 [
					append row-string "  "
					append row-string field-value
				]
				0 2 3 4 5 8 9 [
					append row-string "   "
					append row-string field-value
				]
			]
		]
		append output-string row-string
		append output-string newline
	]
	output-string
]

hor-line: "  ---------------------------- "
xiangqi-display-set: copy ""

init-xiangqi-display-set: func [
	/standard
	/english
	/english2
	/soldier
	/general
	/sng
	/snmg
][	;print ["init-xiangqi-display-set: " standard]
	xiangqi-display-set: ".PpCcRrHhEeAaKk"
	if standard [xiangqi-display-set: ".PpCcRrHhEeAaKk"]
	if english  [xiangqi-display-set: ".PpCcRrNnEeAaKk"]
	if english2 [xiangqi-display-set: ".SsCcRrNnEeAaKk"]
	if soldier  [xiangqi-display-set: ".SsCcRrHhEeAaKk"]
	if general  [xiangqi-display-set: ".SsCcRrHhEeAaGg"]
	if sng      [xiangqi-display-set: ".SsCcRrNnEeAaGg"]
	if snmg     [xiangqi-display-set: ".SsCcRrNnEeMmGg"]
]

init-xiangqi-display-set/standard

; Standard notation for piece that stays on the same row is the equal sign, but a dot "." is sometimes used as well.
STANDARD-SAME-SIGN: copy ""

set-standard-same-sign: func [
	/dot
][
	either dot [
		STANDARD-SAME-SIGN: "."
	][
		STANDARD-SAME-SIGN: "="
	]
]

set-standard-same-sign

display-board: function [
	"Print the board in a readable format"
	in-board [block!]
][
	print compose-output-board-display in-board
]

compose-output-board-display: func [
	"Offer the board in a readable format to be printed or logged"
	in-board [block!]
	return: [string!]
	/numbers
	/local 
	count [integer!] 
	number [integer!] 
	number-string [string!] 
	helpstring [string!]
	output-string [string!]
	set-index [integer!]
][	;print "compose-output-board-display" print xiangqi-display-set
	output-string: copy ""
	append output-string "   1  2  3  4  5  6  7  8  9"
	append output-string newline
	append output-string hor-line
	append output-string newline
	;print output-string
	repeat count 10 [
		number-string: copy " "
		helpstring: copy "  "
		foreach number print-rows/:count [
			set-index: switch in-board/:number [
			    0 [1]
			    2 [2]
			    3 [3]
			    4 [4]
			    5 [5]
			    8 [6]
			    9 [7]
			    16 [8]
			    17 [9]
			    32 [10]
			    33 [11]
			    64 [12]
			    65 [13]
			    128 [14]
			    129 [15]		
			]
			append number-string helpstring
			append number-string xiangqi-display-set/:set-index
		]
		append output-string number-string
		append output-string newline
		
		if numbers [
			number-string: copy " "
			foreach number print-rows/:count [
				if number < 10 [ append number-string " " ]
				append number-string " "
				append number-string number
			]
			append number-string number-string
		]
	]
    append output-string hor-line
	append output-string newline
    append output-string "   9  8  7  6  5  4  3  2  1"
    output-string
]

;********************************
; Routines to translate notations
;********************************
; Our field notation to Chinese notation
notation-to-chinese: function [
	in-board [block!]
	start-field [integer!]
	end-field [integer!]
	return: [string!]
	/local piece [integer!]
	notation [string!]
	start-line [integer!]
	start-row [integer!]
	end-line [integer!]
	end-row [integer!]
	sign [string!]
	set-index [integer!]
][
	if start-field = end-field [return "INVALID MOVE"]
	piece: in-board/:start-field
	set-index: multi-switch piece [
		  2   3 [2]
		  4   5 [4]
		  8   9 [6]
		 16  17 [8]
		 32  33 [10]
		 64  65 [12]
		128 129 [14]
	]
	notation: copy "" 
	append notation xiangqi-display-set/:set-index
	start-line: 1 + ((start-field - 1) / 10)     ; black line number
	if even? piece [start-line: 10 - start-line] ; white counts from right to left
	append notation start-line
	end-line: 1 + ((end-field - 1) / 10)
	if even? piece [end-line: 10 - end-line]
	start-row: 1 + remainder (start-field - 1) 10
	end-row: 1 + remainder (end-field - 1) 10
	either start-row = end-row [
		sign: STANDARD-SAME-SIGN
		append notation sign
		append notation end-line
	][
		either any [all [	even? piece
							end-row > start-row ]
					all [   odd? piece
							end-row < start-row ]
					][
			sign: "+"
		][
			sign: "-"
		]
		append notation sign
		either element-in-collection piece [16 17 32 33 64 65] [
			append notation end-line
		][	
			append notation absolute end-row - start-row
		]
	]
	notation
]

red-pawns-on: [
[ 4  5  6  7  8  9 10]
[      16 17 18 19 20]
[24 25 26 27 28 29 30]
[      36 37 38 39 40]
[44 45 46 47 48 49 50]
[      56 57 58 59 60]
[64 65 66 67 68 69 70]
[      76 77 78 79 80]
[84 85 86 87 88 89 90]
]
 
black-pawns-on: [
[ 1  2  3  4  5  6  7]
[11 12 13 14 15      ]
[21 22 23 24 25 26 27]
[31 32 33 34 35      ]
[41 42 43 44 45 46 47]
[51 52 53 54 55      ]
[61 62 63 64 65 66 67]
[71 72 73 74 75      ]
[81 82 83 84 85 86 87]
]

find-line-with-double-piece: function [
	in-board [block!]
	piece [integer!]
	return: [integer!]
	/local
	value [integer!]
	line [integer!]
	count [integer!]
	pawns-on-fields [block!]
][
	value: 0
	line: 0
	; It says this ia a rare occasion so efficiency is less important
	; Piece cannot be the King/General for each player has only 1
	; If piece is not pawn there are maximal 2 of those per player
	; so if we find one, the other will be on the same file
	; If it is a pawn we need to find both pawns on a file
	either PAWN = (PAWN and piece) [
		pawns-on-fields: either 1 = (BLACK and piece)[black-pawns-on][red-pawns-on]
		foreach fields pawns-on-fields [
			count: 0
			value: value + 1
			foreach field fields [
				if piece = in-board/:field [count: count + 1]
			]
			if 1 < count [line: value]
		]
	][
		count: 0
		until [
			count: count + 1
			if piece = in-board/:count [
				line: 1 + (count - 1 / 10)
				count: 91
			]
			count > 90
		]
	]
	10 - line
]
;find-double-piece-on-line: closest farthest

; Chinese notation to number notation
notation-to-numbers: function [
	notation [string!]
	player-to-move [integer!]
	in-board [block!]
	return: [block!]
	/local piece [integer!]
	line [integer!]
	i [integer!]
	field [integer!]
	start-field [integer!]
	end-field [integer!]
	piece-found [logic!]
	result [block!]
	sign [string!]
	dest [integer!]
	shift-line [integer!]
	first-position [char! string! word!]
	double [char! string!]
][
	result: copy []
	first-position: first notation
	piece: multi-switch first-position [
		#"P" #"p" 
		#"S" #"s" [   2 ]
		#"C" #"c" [   4 ]
		#"R" #"r" [   8 ]
		#"H" #"h"
		#"N" #"n" [  16 ] ; N and n as service
		#"E" #"e" [  32 ]
		#"A" #"a" [  64 ]
		#"K" #"k" 
		#"G" #"g" [ 128 ]
	]
	piece: piece + player-to-move
	;print ["Piece value is now" piece " for first-position:" first-position type? first-position]
	notation: next notation
	double: first notation ; use this helperfield for the rare case there is a double piece on the same file
	line: multi-switch double [
			#"0" [0]
			#"1" [1]
			#"2" [2]
			#"3" [3]
			#"4" [4]
			#"5" [5]
			#"6" [6]
			#"7" [7]
			#"8" [8]
			#"9" [9]
			; on rare occasions two of the same (color and kind) pieces are on the same file
			; This will be noted by a "-" or a "+" sign, meaning closest or farthest piece
			; It is up to the program what file this must be.
			#"-" #"+" [ find-line-with-double-piece in-board piece]
		]
	if 0 = player-to-move [ line: 10 - line ]
	shift-line: line - 1 * 10              ; We use this to add 10*line to get fieldnumber
	notation: next notation
	sign: first notation
	direction: either #"-" = sign [-1][1]
	notation: next notation
	dest: switch first notation [
			#"0" [0]
			#"1" [1]
			#"2" [2]
			#"3" [3]
			#"4" [4]
			#"5" [5]
			#"6" [6]
			#"7" [7]
			#"8" [8]
			#"9" [9]
		]
	; search piece in line
	
	next-field: either any[ all [BLACK = (BLACK and piece)
								#"-" = double]
							all [BLACK <> (BLACK and piece)
								#"+" = double]][
					true
				][
					false
				]
	
	piece-found: false
	i: 1
	until [
		while [all [ 	not piece-found
						i < 11 			]][
			field: i + shift-line
			if piece = in-board/:field [
				either next-field[; Next!!
					next-field: false
				][
					piece-found: true 	
					start-field: field
					; depending on piece type the dest means destination line or advance number of fields
					either any [#"=" = sign
								#"." = sign][ ; destination on same row (i) and destination line is meant
						if 0 = player-to-move [dest: 10 - dest]
						end-field: dest - 1 * 10 + i
					][ ; or sign is +/-
						multi-switch piece [
							2   3  ; Pawn, always +1
							4   5  ; Canon
							8   9  ; Rook
							128 129  ; King
							[
								end-field: (power -1 player-to-move) * dest * direction + start-field
							]
							16 17 [ ; Horse. Horse, Advisor and Elephant never move vertical or horizontal
									if 0 = player-to-move [dest: 10 - dest]
									;print ["Dest : " dest " Line:" line]
									if element-in-collection dest - line [-2 2] [
										;print ["collection -2 2 start-field" start-field "player-to-move" player-to-move "direction" direction]
										end-field: start-field + (10 * (dest - line)) + ((power -1 player-to-move) * direction ) 
									]
									if element-in-collection dest - line [-1 1] [
										;print ["collection -1 1 start-field" start-field "player-to-move" player-to-move "direction" direction]
										end-field: start-field + (10 * (dest - line)) + ((power -1 player-to-move) * direction * 2 )
									]
									;print ["end field :" end-field]
							]
							32 33 [ ; Elephant two rows and two lines
									if 0 = player-to-move [dest: 10 - dest]
									;end-field: start-field + ((power -1 player-to-move) * direction * 10 * (dest - line)) + ((power -1 player-to-move) * direction * 2)
									end-field: start-field + (direction * 10 * (dest - line)) + ((power -1 player-to-move) * direction * 2)
							]
							64 65 [ ; Advisor, one row and one line
									if 0 = player-to-move [dest: 10 - dest]
									;end-field: start-field + ((power -1 player-to-move) * direction * 10 * (dest - line)) + ((power -1 player-to-move) * direction)
									end-field: start-field + (direction * 10 * (dest - line)) + ((power -1 player-to-move) * direction)
							]
						]
					]
				]
			]
			i: i + 1
		]
		if piece-found [
			result: append result start-field
			result: append result end-field
		]
		piece-found: false
		i > 10
	]
	result
]

;*******************
compose-output-move-list: function [
	"Offer the moves list using the internal representation"
	moves-list [block!]
	return: [string!]
	/local
	output-string [string!]
][
	output-string: copy ""
	foreach move moves-list [
		append output-string form move
		append output-string newline
	]
	output-string
]

; Note: this is the list for displaying moves in console mode
; so the user can choose a move by selecting a number
; selecting the correct move is easy from the original list taking the x'th element.
compose-console-move-list: function [
	"Make a string of numbered moves in Chinese notation"
	in-board [block!]
	moves-list [block!]
	return: [string!]
	/local
	count [integer!]
	dot-space [string!]
	output-string [string!]
	start-field  [integer!]
	end-field [integer!]
][
	count: 1
	output-string: copy ""
	dot-space: ". "
	foreach move move-list [
		either 10 > count [
			append output-string "    "
		][
			append output-string "   "
		]			
		append output-string count
		append output-string dot-space
		start-field: move/2 ; todo: check this
		end-field: move/3
		append output-string notation-to-chinese in-board start-field end-field
		if 0 = remainder count 4 [
			append output-string newline
		]
		count: count + 1
	]
	output-string
]