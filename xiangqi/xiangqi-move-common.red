Red [
	"Common values for move generating and influence for Xiangqi aka Chinese Chess"
	filename: %xiangqi-move-common.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "23-Feb-2015"
]

;********************
; Move formats
;********************
; Perhaps it is of value to have different formats for the moves in the move list?
; Standard format
; this-move: reduce [piece-value m n captured giving-check board-change-value]
MOVE-ELEMENTS: 6
CHECK-INDICATOR: 5
; other possible formats
; this-move: reduce [m n]
; this-move: reduce [piece-value m n hash-value-resulting-position]
; Not yet implemented

;********************
; Move tables
;********************
king-moves: [ 
	; Red King
	31 [41 32]
	32 [31 33 42]
	33 [32 43]
	41 [31 42 51]
	42 [32 41 43 52]
	43 [32 42 53]
	51 [41 52]
	52 [42 51 53]
	53 [43 52]
	; Black King
	38 [39 48]
	39 [38 40 49]
	40 [39 50]
	48 [38 49 58]
	49 [39 48 50 59]
	50 [40 49 60]
	58 [48 59]
	59 [49 58 60]
	60 [50 59]
]

; Advisor or Guard or Minister or Mandarin (64 or 65)
advisor-moves: [
	; Red Advisor
	31 [42]
	33 [42]
	42 [31 33 51 53]
	51 [42]
	53 [42]
	; Black Advisor
	38 [49]
	40 [49]
	49 [38 40 58 60]
	58 [49]
	60 [49]
]

; Elephant (32 or 33)
elephant-moves: [
	; Red Elephant
	 3 [[12 21] [14 25]]
	21 [[12  3] [32 43]]
	25 [[14  3] [34 43]]
	43 [[32 21] [34 25] [52 61] [54 65]]
	61 [[52 43] [72 83]]
	65 [[54 43] [74 83]]
	83 [[72 61] [74 65]]
	; Black Elephant
	 8 [[17 26] [19 30]]
	26 [[17  8] [37 48]]
	30 [[19  8] [39 48]]
	48 [[37 26] [39 30] [57 66] [59 70]]
	66 [[57 48] [77 88]]
	70 [[59 48] [79 88]]
	88 [[77 66] [79 70]]
]

piece-color: function [
	piece-value [integer!]
	return: [integer!]
][
	piece-value and 1
]

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
