Red [
	"Hash computing for the game of xiangqi aka Chinese Chess"
	filename: %xiangqi-hash.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "31-Oct-2014"
	documentation: "In file %docs/Xiangqi-hash.rtf"
	testfile: "Using file %test/xiangqi-hash-test.red"
	functions-description: { 
		functions to be called:
		-	calculate-hash-code	
				input: board
				output: hash-code as string
		-	calculate-new-hash-code-from-move
				input: board hash move-from move-to
				output: hash-code as string
		private functions:
		-	sextant
		-	init-hash
		-	calculate-hash
		-	calculate-new-hash-from-move
		-	integer-to-base64
		-	convert-to-base64
		used constants and variables
		-	multiplication-table
		-	hash-area
		-	hash
		-	empty-hash
		-	base64-chars
	}
]

comment {
The sextant function. The idea is when a move is done the hash-value should be recalculated
but the way we do this is only for the one or 2 sextants the move is affecting.
}

sextant: function [
	"Compute the part of the board for this field"
	fieldnumber [integer!]
	return: [integer!]
] [
	fieldnumber: fieldnumber - 1
	( fieldnumber / 30 )  + either 4 < ( remainder fieldnumber 10) [4][1]
]

comment {
The idea is we can compute unique numbers for each sextant representing the parts of the 
board by multiplying the fieldnumber with the piece on it, and adding these values 
together for each sextant. The multiplication table helps making the values unique.
}
 
multiplication-table: [
13  23  37  47  61    61  47  37  23  13
11  21  31  43  59    59  43  31  21  11
 7  19  29  41  53    53  41  29  19   7

11  21  31  43  59    59  43  31  21  11
 7  19  29  41  53    53  41  29  19   7
13  23  37  47  61    61  47  37  23  13

 7  19  29  41  53    53  41  29  19   7
11  21  31  43  59    59  43  31  21  11
13  23  37  47  61    61  47  37  23  13
]

; Define the area for each hash value
hash-area: [
	[ 1  2  3  4  5 11 12 13 14 15 21 22 23 24 25]
	[31 32 33 34 35 41 42 43 44 45 51 52 53 54 55]
	[61 62 63 64 65 71 72 73 74 75 81 82 83 84 85]
	[ 6  7  8  9 10 16 17 18 19 20 26 27 28 29 30]
	[36 37 38 39 40 46 47 48 49 50 56 57 58 59 60]
	[66 67 68 69 70 76 77 78 79 80 86 87 88 89 90]
]

hash: copy []
empty-hash: [0 0 0 0 0 0]

init-hash: does [
	hash: copy empty-hash
]

calculate-hash: function [
	board [block!]
	return: [block!]
] [
	init-hash
	repeat area 6 [
		foreach field hash-area/:area [
			if 0 < board/:field [
				hash/:area: board/:field * multiplication-table/:field + hash/:area 
			]
		]
	]
	hash
]

calculate-new-hash-from-move: function [
	board [block!]
	hash [block!]
	move-from [integer!]
	move-to [integer!]
	return: [block!]
	/local area a b 
] [
	a: sextant move-from
	b: sextant move-to
	piece: board/:move-from
	to-field-value: board/:move-to
	hash/:a: hash/:a - (piece * multiplication-table/:move-from)
	hash/:b: hash/:b - (to-field-value * multiplication-table/:move-to) + (piece * multiplication-table/:move-to)
	hash
]

;***********************************
; Hash block to a base64 like string
;***********************************
base64-chars: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

integer-to-base64: function [
	id [integer!]
	return: [string!]
	/local out
][
	out: copy ""
	while [id > 0][
		;insert out base64-chars/(id // 64 + 1)
		insert out base64-chars/(1 + remainder id 64)
		id: id / 64
	]
	out
]

convert-to-base64: function [
	key [block!]
	return: [string!]
	/local i [integer!] out [string!] part [string!]
][
	out: copy ""
	foreach i [2 5 1 4 3 6] [
		part: integer-to-base64 key/:i
		while [3 > length? part][ insert part "A" ]
		append out part
	]
	out
]

calculate-hash-code: function [
	board [block!]
	return: [string!]
] [
	convert-to-base64 calculate-hash board
]

calculate-new-hash-code-from-move: function [
	board [block!]
	in-hash [block!]
	move-from [integer!]
	move-to [integer!]
	return: [string!]
][
	convert-to-base64 calculate-new-hash-from-move board in-hash move-from move-to
]

comment { 
                                       [1    2    3   4   5    6]
Hash block of start position should be [804  2514 804 954 2586 954]
                                       [2    5    1   4   3    6]
Hash code of start position should be  "AnS  Aoa  AMk AO6 AMk  AO6"
                                        2514 2586 804 954 804  954
}