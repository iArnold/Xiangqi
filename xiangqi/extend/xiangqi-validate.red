Red [
	"Validate input for the game of xiangqi aka Chinese Chess"
	filename: %xiangqi-validate.red
	author:   "Arnold van Hofwegen"
	version:  0.2
	date:     "19-Feb-2015"
	testfile: "Using file %test/xiangqi-validate-test.red"
	functions-description: { 
		functions to be called:
		-	validate-board
				input: board
				output: boolean
	}
	red-version: "Needs Red 0.5.0"
	needs:    "%xiangqi-common.red #include via main program or testprogram"
]

comment {
	Known issue: at the moment *Compiled* Red does not handle multiple choices in a switch correctly
	This was not an issue while testing in the interpreter.
	
	Until this will be fixed this is solved by using my own multi-switch and the function
	element-in-collection.
}

;***********************
; Validation of position
;***********************
validate-board: func [	
	"Determine if the position of pieces on the board is legitimate"
	board [block!]
	return: [logic!]
	/local	red-king [integer!] black-king [integer!]
	red-king-line [integer!] black-king-line [integer!] red-king-row [integer!] black-king-row [integer!]
	red-king-field [integer!] black-king-field [integer!]
	red-advisor [integer!]   red-elephant [integer!]   red-canon [integer!]   red-knight [integer!]   red-pawn [integer!]   red-chariot [integer!]
	black-advisor [integer!] black-elephant [integer!] black-canon [integer!] black-knight [integer!] black-pawn [integer!] black-chariot [integer!]
	j [integer!] sum [integer!] share-info [logic!]
][
	share-info: any [ 	debug
						report-info ]
	if 90 <> length? board [
		if share-info [
			info-area/code: 1 
			info-area/description: reduce ["Board has wrong number of fields: " length? board]
		] 
		return false
	]
	red-king: red-advisor: red-chariot: red-elephant: red-knight: red-canon: red-pawn:  0
	black-king: black-advisor: black-chariot: black-elephant: black-knight: black-canon: black-pawn:  0
	repeat i 90 [
		either element-in-collection board/:i [0 2 3 4 5 8 9 16 17 32 33 64 65 128 129] [
			switch board/:i [
				0 [ ]
				2 [	red-pawn: red-pawn + 1 
					; Red pawns must be on other side of the board or on start position or one field advanced from the start
					if element-in-collection i [
						 1  2  3 
						11 12 13 14 15
						21 22 23 
						31 32 33 34 35
						41 42 43
						51 52 53 54 55
						61 62 63
						71 72 73 74 75
						81 82 83       ][
						if share-info [
							info-area/code: 2 
							info-area/description: reduce ["Red Pawn found on faulty position: " i]
						] 
						return false
					]
				]
				3 [	black-pawn: black-pawn + 1 
					; Black pawns must be on other side of the board or on start position or one field advanced from the start
					if element-in-collection i [
						       8  9 10 
						16 17 18 19 20
						      28 29 30 
						36 37 38 39 40
						      48 49 50
						56 57 58 59 60
						      68 69 70
						76 77 78 79 80
						      88 89 90 ][
						if share-info [
							info-area/code: 3 
							info-area/description: reduce ["Black Pawn found on faulty position: " i]
						] 
						return false
					]
				]
				4 [	red-canon: red-canon + 1 ]
				5 [	black-canon: black-canon + 1 ]
				8 [	red-chariot: red-chariot + 1 ]
				9 [	black-chariot: black-chariot + 1 ]
				16 [	red-knight: red-knight + 1 ]
				17 [	black-knight: black-knight + 1 ]
				32 [	red-elephant: red-elephant + 1 
						; Elephant can only be on 7 fields
						if not element-in-collection i [3 21 25 43 61 65 83][
							if share-info [
								info-area/code: 4 
								info-area/description: reduce ["Red Elephant found on faulty position: " i]
							] 
							return false
						]
				]
				33 [	black-elephant: black-elephant + 1 
						; Elephant can only be on 7 fields
						if not element-in-collection i [8 26 30 48 66 70 88][ 
							if share-info [
								info-area/code: 5 
								info-area/description: reduce ["Black Elephant found on faulty position: " i]
							] 
							return false
						]
				]
				64 [	red-advisor: red-advisor + 1 
						; Advisor in palace on allowed fields
						if not element-in-collection i [31 33 42 51 53][
							if share-info [
								info-area/code: 6 
								info-area/description: reduce ["Red Advisor found on faulty position: " i]
							] 
							return false
						]
				]
				65 [	black-advisor: black-advisor + 1 
						; Advisor in palace on allowed fields
						if not element-in-collection i [38 40 49 58 60][
							if share-info [
								info-area/code: 7 
								info-area/description: reduce ["Black Advisor found on faulty position: " i]
							] 
							return false
						]
				]
				128 [	red-king-field: i
						red-king: red-king + 1
						red-king-line: 1 + ((i - 1) / 10)
						red-king-row: 1 + remainder (i - 1) 10 
						; King in his palace
						if not element-in-collection i [31 32 33 41 42 43 51 52 53][ 
							if share-info [
								info-area/code: 8 
								info-area/description: reduce ["Red King found on faulty position: " i]
							] 
							return false
						]
				]
				129 [	black-king-field: i
						black-king: black-king + 1
						black-king-line: 1 + ((i - 1) / 10)
						black-king-row: 1 + remainder (i - 1) 10 
						; King in his palace
						if not element-in-collection i [38 39 40 48 49 50 58 59 60][
							if share-info [
								info-area/code: 9 
								info-area/description: reduce ["Black King found on faulty position: " i]
							] 
							return false
						]
				]
			]
		] [ ; Former switch/default, unknown piece on the board
			if share-info [
				info-area/code: 10 
				info-area/description: reduce ["Unknown piece " board/:i " found on field: " i]
			] 
			return false
		]
	]
	
	if any [	red-king <> 1
				black-king <> 1
				red-king-line > 6
				red-king-line < 4
				black-king-line > 6
				black-king-line < 4
				red-king-row > 3
				black-king-row < 8
				red-advisor > 2
				black-advisor > 2
				red-elephant > 2
				black-elephant > 2
				red-knight > 2
				black-knight > 2
				red-chariot > 2
				black-chariot > 2
				red-canon > 2
				black-canon > 2
				red-pawn > 5
				black-pawn > 5
	][
		if share-info [
			info-area/code: 11 
			info-area/description: reduce ["Incorrect number of pieces found"]
		] 
		return false
	]
	; red pawn maximum of 1 pawn in [4 5], [24 25], [44 45], [64 65], [84 85]
	if 1 < red-pawn [ ; no use of testing for doubles if only 1 red pawn present
		if any [ all [	2 = board/4
						2 = board/5 ]
				 all [	2 = board/24
						2 = board/25 ]
				 all [	2 = board/44
						2 = board/45 ]
				 all [	2 = board/64
						2 = board/65 ]
				 all [	2 = board/84
						2 = board/85 ] ] [ 
			if share-info [
				info-area/code: 12 
				info-area/description: reduce ["Doubled red pawn found where not allowed"]
			] 
			return false
		]
	]
	; black pawn maximum of 1 pawn in [6 7],  [26 27], [46 47], [66 67], [86 87]
	if 1 < black-pawn [ ; no use of testing for doubles if only 1 black pawn present
		if any [ all [	3 = board/6
						3 = board/7 ]
				 all [	3 = board/26
						3 = board/27 ]
				 all [	3 = board/46
						3 = board/47 ]
				 all [	3 = board/66
						3 = board/67 ]
				 all [	3 = board/86
						3 = board/87 ] ] [ 
			if share-info [
				info-area/code: 13 
				info-area/description: reduce ["Doubled black pawn found where not allowed"]
			] 
			return false
		]
	]
	
	if red-king-line = black-king-line [
		sum: 0
		j: red-king-field + 1
		while [ all [	sum = 0
						j <> black-king-field]][
			sum: sum + board/:j
			j: j + 1
		]
		if sum = 0 [ 
			if share-info [
				info-area/code: 14 
				info-area/description: reduce ["The two Kings can see each other."]
			] 
			return false 
		]
	]
	true
]