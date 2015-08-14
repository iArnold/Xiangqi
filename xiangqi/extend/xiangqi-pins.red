Red [
	"Get information on pinned pieces on the board of Xiangqi aka Chinese Chess"
	filename: %xiangqi-pins.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "09-Feb-2015"
]

;******************************
; Get the pinned pieces
;******************************
horse-from-king: [
31 [21 [12] 32 [23 43] 41 [52]]
32 [22 [11 13] 33 [24 44] 42 [51 53]]
33 [23 [12 14] 34 [25 45] 42 [51 53] 32 [21 41]]
41 [31 [22] 42 [33 53] 51 [62]]
42 [32 [21 23] 43 [34 54] 52 [61 63]]
43 [33 [22 24] 44 [35 55] 53 [62 64] 42 [31 51]]
51 [41 [32] 52 [43 63] 61 [72]]
52 [42 [31 33] 53 [44 64] 62 [71 73]]
53 [43 [32 34] 54 [45 65] 63 [72 74] 52 [41 61]]
38 [28 [17 19] 37 [26 46] 48 [57 59] 39 [30 50]]
39 [29 [18 20] 38 [27 47] 49 [58 60]]
40 [30 [19] 39 [28 48] 50 [59]]
48 [38 [27 29] 47 [36 56] 58 [67 69] 49 [40 60]]
49 [39 [28 30] 48 [37 57] 59 [68 70]]
50 [40 [29] 49 [38 58] 60 [69]]
58 [48 [37 39] 57 [46 66] 68 [77 79] 59 [50 70]]
59 [49 [38 40] 58 [37 67] 69 [78 80]]
60 [50 [39] 59 [48 68] 70 [79]]
]

pin-list: copy []

clear-pin-list: does [
	pin-list: copy []
]

get-pins: function [ 
	in-board [block!]
	color    [integer!]
	return: [integer!]
	/full   ; Also get 'pinned' enemy pieces, these are enemy pieces that can be moved to set a check by the pinning enemy piece of.
	/local own-king-pos [integer!]
	other-king-pos [integer!]
	kings-row [integer!]
	field [integer!]
	field-value [integer!]
	steps [block!]
	down-limit [integer!]
	up-limit [integer!]
	own-color [logic!]
][
	clear-pin-list
	own-king-pos: get-field-king in-board color
	other-king-pos: get-field-king in-board 1 - color
	
	; pawn, elephant, advisor cannot pin other pieces.
	; check horse
	horse-fields: select horse-from-king own-king-pos
	; now we have possible blocks
	foreach [jump-over from-fields] horse-fields [
		if 0 < in-board/:jump-over [ ; a piece that can be pinned by a horse
			own-color: not (BLACK = (color xor (BLACK and field-value)))
			foreach field from-fields [
				field-value: in-board/:field
				if all [KNIGHT = (KNIGHT and field-value)
						BLACK = (color xor (BLACK and field-value)) ][
					; add pin to pin-list
					if any [full											; full refinement
							own-color ][									; own colored piece is pinned
						append/only pin-list reduce [in-board/:jump-over jump-over field-value field]
					]
				]
			]
		]
	]

	; check rook
	; to the left, to the right, down and up
	steps: [-10 10 -1 1]
	foreach step steps [
		switch/default step [
			case -1 1 [
				switch own-king-pos [
					case 31 32 33 38 39 40 [
						down-limit: 30
						up-limit: 41
					]
					case 41 42 43 48 49 50 [
						down-limit: 40
						up-limit: 51
					]
					case 51 52 53 58 59 60 [
						down-limit: 50
						up-limit: 61
					]
				]
			]
		][
			down-limit: 0
			up-limit: 91
		]
		field: own-king-pos + step
		number-pieces: 0
		remember-pins: [0 0 false]
		while [	any [field > down-limit
					 field < up-limit  ]] [
			field-value: in-board/:field
			if 0 < field-value [
				own-color: not (BLACK = (color xor (BLACK and field-value)))
				if all [1 = number-pieces
						ROOK = (ROOK and field-value)
						BLACK = (color xor (BLACK and field-value)) ][
					if any [full
							remember-pins/3][
						append/only pin-list reduce [remember-pins/1 remember-pins/2 field-value field]
					]
				]
				remember-pins: reduce [field-value field own-color]
				number-pieces: number-pieces + 1
			]
			field: field + step
		]
	]

	; check canon
	; to the left, to the right, down and up
	steps: [-10 10 -1 1]
	foreach step steps [
		switch/default step [
			case -1 1 [
				switch own-king-pos [
					case 31 32 33 38 39 40 [
						down-limit: 30
						up-limit: 41
					]
					case 41 42 43 48 49 50 [
						down-limit: 40
						up-limit: 51
					]
					case 51 52 53 58 59 60 [
						down-limit: 50
						up-limit: 61
					]
				]
			]
		][
			down-limit: 0
			up-limit: 91
		]
		field: own-king-pos + step
		number-pieces: 0
		remember-pins: [0 0 false]
		while [	any [field > down-limit
					 field < up-limit  ]] [
			field-value: in-board/:field
			if 0 < field-value [
				if all [2 = number-pieces
						CANON = (CANON and field-value)
						BLACK = (color xor (BLACK and field-value)) ][
					foreach [fldval fld ownpc] remember-pins [
						if any [full
								ownpc][
							append/only pin-list reduce [fldval fld field-value field]
						]
				]
				either 0 = remember-pins/1 [
					remember-pins: reduce [field-value field own-color]
				][
					append remember-pins reduce [field-value field own-color]
				]
				number-pieces: number-pieces + 1 
			]
			field: field + step
		]
	]

	; other king, king can pin other pieces from moving out of the way.
	
	if any [ all [ found? find [31 32 33 38 39 40] own-king-pos
				   found? find [31 32 33 38 39 40] other-king-pos]
			 all [ found? find [41 42 43 48 49 50] own-king-pos
			 	   found? find [41 42 43 48 49 50] other-king-pos]
			 all [ found? find [51 52 53 58 59 60] own-king-pos
				   found? find [51 52 53 58 59 60] other-king-pos]][
		down-limit: min own-king-pos other-king-pos
		up-limit: max own-king-pos other-king-pos
		number-pieces: 0
		remember-pins: [0 0 false]
		field: down-limit + 1
		while [field < up-limit][
			field-value: in-board/:field
			if 0 < field-value [
				own-color: not (BLACK = (color xor (BLACK and field-value)))
				remember-pins: reduce [field-value field own-color]
				number-pieces: number-pieces + 1
			]
			field: field + 1
		]
		if 1 = number-pieces [
			if any [full
					own-color][
				append/only pin-list reduce [remember-pins/1 remember-pins/2 KING + color other-king-pos]
			]
		]
	]
	return true
]