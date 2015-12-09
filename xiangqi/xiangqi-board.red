Red [
	"Playing Xiangqi in Red with simple GUI"
	filename: %xiangqi-board.red
	author:   "Arnold van Hofwegen"
	version:  0.6.0
	date:     "09-Dec-2015"
	Needs: 'View
]

system/view/debug?: no
live?: system/view/auto-sync?: no

workstation?: system/view/platform/product = 1

print [
	"Windows" switch system/view/platform/version [
		10.0.0	[pick ["10"			 "10 Server"	 ] workstation?]
		6.3.0	[pick ["8.1"		 "Server 2012 R2"] workstation?]
		6.2.0	[pick ["8"			 "Server 2012"	 ] workstation?]
		6.1.0	[pick ["7"			 "Server 2008 R1"] workstation?]
		6.0.0	[pick ["Vista"		 "Server 2008"	 ] workstation?]
		5.2.0	[pick ["Server 2003" "Server 2003 R2"] workstation?]
		5.1.0	["XP"]
		5.0.0	["2000"]
	] 
	"build" system/view/platform/build
]

; Import some xiangqi programs

; Common definitions
#include %xiangqi-common.red

; Move generation
#include %xiangqi-move-common.red
#include %xiangqi-moves-gui.red

; Notation conversion and conversion between board and screen values of fields
#include %xiangqi-convertions.red
#include %utils/red-found.red

;-- Initialize board margin and field size ----

margin-board: margin-x: margin-y: 20
margins: 0x0
margins/1: margin-x
margins/2: margin-y

field-size: 0x0
field-width: field-height: 40
field-size/1: field-width
field-size/2: field-height

image-height: image-width: 30
image-size: 0x0
image-size/1: image-width
image-size/2: image-height
half-image-size: image-size / 2

half-field: 0x0
half-field/1:  field-width / 2
half-field/2: field-height / 2

correction-offset: 0x0
correction-offset/1: correction-offset/2: margin-board
canvas-offset: 10x10
correction-offset: correction-offset + canvas-offset - half-image-size

drag-saved-offset: 0x0

; Move variables
move-list: copy []
play-board: copy start-board
move-list: make-move-list play-board 0
play-moves: display-moves-list move-list
played-moves-list: copy []

computer-has: BLACK-1
move-for-color: RED-0

new-game-as: func [
	player-color [integer!]
][
	move-for-color: RED-0
	
	play-board: copy start-board
	move-list: make-move-list play-board move-for-color
	play-moves: display-moves-list move-list

	computer-has: either player-color = RED-0 [BLACK-1][RED-0]
	
	played-moves-list: copy []
	
	;replace all pieces on the board
	board-pieces: copy all-pieces
]

gui-play-move: func [
	move-from [pair!]
	move-to [pair!]
	/local field-from [integer!]
		field-to [integer!]
		piece [integer!]
		capture-value [integer!]
		move [block!]
		piece-id [string!]
][
	field-from: xy-to-field move-from
	field-to:   xy-to-field move-to
	piece: play-board/:field-from
	capture-value: play-board/:field-to
	move: copy []
	append move piece
	append move field-from
	append move field-to
	append move capture-value
	if 0 < capture-value [
		; get face/id from piece
		board-pieces: head board-pieces
		back find board-pieces move-to
		piece-id: board-pieces/1
		board-pieces: head board-pieces
		append move piece-id
		show-hide-piece-face move-to no ; false means to hide
	]
	append/only played-moves-list move
	play-board/:field-to: piece
	play-board/:field-from: 0
]

gui-undo-last-move: func [
	/local move [block!] 
		dest [integer!] 
		val  [integer!]
		piece [integer!] 
		origin [integer!]
		reset-piece [block!]
	    reset-piece-string [string!]
][
	move: last played-moves-list
	piece: move/1
	origin: move/2
	dest: move/3
	val: move/4
	play-board/:dest: val 
	play-board/:origin: piece

	; place the played piece back to where it came from
	find board-pieces dest
	board-pieces/1: origin
	board-pieces: head board-pieces

	; size of a captured piece was set to 0x0 and the piece-id (face/id) was saved in the move.
	; remember later to make move an object, should be cleaner code
	if 0 < val [
		; find the piece
		back find board-pieces move/5
		piece-name: board-pieces/1
		
		reset-piece-string: copy ""
		append reset-piece-string piece-name
		append reset-piece-string "/size: " 
		append reset-piece-string image-size

		reset-piece: load reset-piece-string
		do reset-piece
	]
	; now remove the last move from the list of played moves
	take/last played-moves-list	
]

take-back-move: func [
][
	if 0 = length? played-moves-list [ return 0 ]
	;undo last move 
	;gui-undo-last-move
	either 0 < length? played-moves-list [
		;undo last move 
		;gui-undo-last-move
	][
		; if computer is red/white play a new move
		if RED-0 = computer-has [
			; compute the best move
			
		]
	]
	return 0
]

; function to go from face/offset to x y coordinates.
face-offset-to-xy: func [
	in [pair!]
	return: [pair!]
	/local out [pair!] xco [integer!] yco [integer!]
][
	out: in
	out/1: out/1 / field-height
	out/2: out/2 / field-width
	out
]

; Simple declaration of all pieces needed for compilation, 
; the definitions are made at runtime to be flexible in size and place
white-king: 
white-advisor-1: 
white-advisor-2: 
white-elephant-1: 
white-elephant-2:
white-horse-1: 
white-horse-2: 
white-chariot-1: 
white-chariot-2: 
white-canon-1: 
white-canon-2:
white-pawn-1:
white-pawn-2:
white-pawn-3:
white-pawn-4:
white-pawn-5:

black-king:
black-advisor-1:
black-advisor-2:
black-elephant-1:
black-elephant-2:
black-horse-1:
black-horse-2:
black-chariot-1:
black-chariot-2:
black-canon-1:
black-canon-2:
black-pawn-1:
black-pawn-2:
black-pawn-3:
black-pawn-4:
black-pawn-5: make face! []

;-- actors

image-actors: object [
		on-over: function [face [object!] event [event!]][
;			print ["Event over" event/offset event/away?]
			if not face/drag [  ;do not recompute when dragging a piece around
				either event/away? [
					hints-canvas/draw: copy []
				][
					relative-offset: 0x0
					relative-offset: face/offset - left-upper-corner/offset - canvas/offset - margins + field-size
					fotxy: face-offset-to-xy relative-offset
					fotxy-field: xy-to-field fotxy
;					if any [0 > fotxy/1
;							0 > fotxy/2
;							8 < fotxy/1
;							9 < fotxy/2 ][ ;-- do not test drops off board yet
						mydestinations: select play-moves fotxy-field
						face/dest: mydestinations
						if not empty? mydestinations [
							hints-block: copy [pen red fill-pen 255.0.0.50 ]
							foreach dest mydestinations [
								place: dest * 40 + 20x20
								append hints-block 'circle
								append hints-block place
								append hints-block 20
							]
							;probe hints-block
							hints-canvas/draw: copy hints-block
							show hints-canvas
						]
;					]
				]
			]
		]
		
		on-drag-start: func [face [object!] event [event!]][
			;print ["drag starts at" event/offset face/offset]
			drag-saved-offset: face/offset
			face/drag: true
		]
		
		on-drop: function [face [object!] event [event!]][
			print ["dropping" event/offset face/offset]
			either empty? face/dest [
				face/offset: drag-saved-offset
			][
				relative-offset: 0x0
				relative-offset: face/offset - left-upper-corner/offset - correction-offset + half-field
				
				either any [0 > relative-offset/1 
							0 > relative-offset/2][
					print "Negative piece put back"
					face/offset: drag-saved-offset
				][
					drop-fotxy: face-offset-to-xy relative-offset
					either any [ 8 < drop-fotxy/1
							 	 9 < drop-fotxy/2 ][
						face/offset: drag-saved-offset
					][ 
						either found? find face/dest drop-fotxy [
							drop-fotxy: drop-fotxy * field-size + half-image-size - half-field
							; Because win/offset is on the outside of the window, generally a difference of 8x30 or 8x50
							face/offset: left-upper-corner/offset + margins + drop-fotxy
						][
							face/offset: drag-saved-offset
						]
					]
				]
			]
			
			face/drag: false
			hints-canvas/draw: copy []

		]
]

; Pieces to be placed on the canvas
all-pieces: [
	; piece		 		id	 offset piece-Type Western/Traditional(art) color
	"white-king"       "WK"  4x9 "General"  "T" "R"
	"white-advisor-1"  "WA1" 3x9 "Advisor"  "T" "R"
	"white-advisor-2"  "WA2" 5x9 "Advisor"  "T" "R"
	"white-elephant-1" "WE1" 2x9 "Elephant" "T" "R"
	"white-elephant-2" "WE2" 6x9 "Elephant" "T" "R"
	"white-horse-1"    "WH1" 1x9 "Horse"    "T" "R"
	"white-horse-2"    "WH2" 7x9 "Horse"    "T" "R"
	"white-chariot-1"  "WR1" 0x9 "Chariot"  "T" "R"
	"white-chariot-2"  "WR2" 8x9 "Chariot"  "T" "R"
	"white-canon-1"    "WC1" 1x7 "Cannon"   "T" "R"
	"white-canon-2"    "WC2" 7x7 "Cannon"   "T" "R"
	"white-pawn-1"     "WP1" 0x6 "Soldier"  "T" "R"
	"white-pawn-2"     "WP2" 2x6 "Soldier"  "T" "R"
	"white-pawn-3"     "WP3" 4x6 "Soldier"  "T" "R"
	"white-pawn-4"     "WP4" 6x6 "Soldier"  "T" "R"
	"white-pawn-5"     "WP5" 8x6 "Soldier"  "T" "R"
	
	"black-king"       "BK"  4x0 "General"  "T" "B"
	"black-advisor-1"  "BA1" 3x0 "Advisor"  "T" "B"
	"black-advisor-2"  "BA2" 5x0 "Advisor"  "T" "B"
	"black-elephant-1" "BE1" 2x0 "Elephant" "T" "B"
	"black-elephant-2" "BE2" 6x0 "Elephant" "T" "B"
	"black-horse-1"    "BH1" 1x0 "Horse"    "T" "B"
	"black-horse-2"    "BH2" 7x0 "Horse"    "T" "B"
	"black-chariot-1"  "BR1" 0x0 "Chariot"  "T" "B"
	"black-chariot-2"  "BR2" 8x0 "Chariot"  "T" "B"
	"black-canon-1"    "BC1" 1x2 "Cannon"   "T" "B"
	"black-canon-2"    "BC2" 7x2 "Cannon"   "T" "B"
	"black-pawn-1"     "BP1" 0x3 "Soldier"  "T" "B"
	"black-pawn-2"     "BP2" 2x3 "Soldier"  "T" "B"
	"black-pawn-3"     "BP3" 4x3 "Soldier"  "T" "B"
	"black-pawn-4"     "BP4" 6x3 "Soldier"  "T" "B"
	"black-pawn-5"     "BP5" 8x3 "Soldier"  "T" "B"
]

board-pieces: copy all-pieces

image-path: %images/

show-hide-piece-face: func [
	xy-pair [pair!]
	show? [logic!]
	/local
		reset-piece [block!]
	    reset-piece-string [string!]
		p [string!] 
		piece-offset [pair!]
][
	board-pieces: head board-pieces
	board-pieces: find board-pieces xy-pair

	board-pieces: back back board-pieces
	p: copy first board-pieces

	reset-piece-string: copy ""
	append reset-piece-string p
	append reset-piece-string "/size: " 
	append reset-piece-string either show? [image-size]["0x0"]

	reset-piece: load reset-piece-string
	do reset-piece

	board-pieces: head board-pieces
]

set-piece-on-top: func [
	piece-name [string!]
	/local face-object [object!] 
][
	piece-panel/pane: find piece-panel/pane piece-name
	face-object: first piece-panel/pane
	remove/part piece-panel/pane 1
	piece-panel/pane: head piece-panel/pane
	append piece-panel/pane face-object
]

set-piece-face: func [
	xy-pair [pair!]
	to-pair [pair!]
	/local
		reset-piece [block!]
	    reset-piece-string [string!]
		p [string!] 
		piece-offset [pair!]
][
	board-pieces: head board-pieces
	board-pieces: find board-pieces xy-pair
	board-pieces/1: to-pair
	
	board-pieces: back back board-pieces
	p: copy first board-pieces

	reset-piece-string: copy ""
	append reset-piece-string p
	piece-offset: 0x0
	piece-offset: to-pair * field-size + correction-offset
	append reset-piece-string "/offset: " 
	append reset-piece-string piece-offset

	append reset-piece-string p
	append reset-piece-string "/size: " 
	append reset-piece-string image-size

	reset-piece: load reset-piece-string
	do reset-piece

	board-pieces: head board-pieces
]

reset-pieces-faces: func [
	/local 
		reset-piece [block!]
	    reset-piece-string [string!]
		p [string!] i [string!] t [string!] a [string!] c [string!]
		o [pair!]
		piece-offset [pair!]
][
	board-pieces: copy all-pieces
	foreach [p i o t a c] board-pieces [
		piece-offset: 0x0
		piece-offset: o * field-size + correction-offset
		reset-piece-string: copy ""
		append reset-piece-string p
		append reset-piece-string "/offset: " 
		append reset-piece-string piece-offset
		append reset-piece-string " " 
		append reset-piece-string p
		append reset-piece-string "/size: " 
		append reset-piece-string image-size
		reset-piece: load reset-piece-string
		do reset-piece
	]
]

make-piece-faces: func [
	/local 
		declare-piece [block!]
		declare-piece-string [string!]
		p [string!] i [string!] t [string!] a [string!] c [string!]
		o [pair!]
		piece-offset [pair!]
][
	foreach [p i o t a c] board-pieces [
		; declare piece image
		declare-piece: copy []
		declare-piece-string: copy ""

		append declare-piece-string p
	
		append declare-piece-string ": make face! ["
		append declare-piece-string newline
		append declare-piece-string "type: 'base offset: "

		piece-offset: 0x0
		piece-offset: o * field-size + correction-offset
		append declare-piece-string piece-offset

print ["piece " p " at " piece-offset]
		append declare-piece-string " size: "
		append declare-piece-string image-size
		append declare-piece-string newline
		append declare-piece-string "image: load %"
		append declare-piece-string image-path 
		append declare-piece-string "Xiangqi_"
		append declare-piece-string t
		append declare-piece-string "_"
		append declare-piece-string a
		append declare-piece-string c
		append declare-piece-string ".png"
		append declare-piece-string newline
		append declare-piece-string "	options: [drag-on: 'down]"
		append declare-piece-string newline
		append declare-piece-string {	id: "}
		append declare-piece-string i
		append declare-piece-string {"}
		append declare-piece-string newline
		append declare-piece-string "	actors: image-actors"
		append declare-piece-string newline
		append declare-piece-string " dest: copy [] drag: false ]"
		
		;print declare-piece-string 
		
		; perform the declaration 		
		declare-piece: load declare-piece-string
		do declare-piece		

	]	; end foreach piece
	print declare-piece-string
]

make-piece-faces 

; Declaring the window
win: make face! [
	type: 'window text: "Xiangqi in Red by: Arnold" offset: 300x200 size: 400x600
]

; -- Declare window pane
win/pane: reduce [

	; Help positioning dropped piece relative to the inside of the window
	left-upper-corner: make face! [ 
		type: 'base 
		offset: 0x0
		size: 0x0
	]
	
	black-to-move: make face! [
		type: 'base offset: 375x10
		size: 20x20 color: blue
	]
	
	red-to-move: make face! [
		type: 'base offset: 375x390
		size: 20x20 color: red
	]
			
	canvas: make face! [
		type: 'base text: "Xiangqi in Red" offset: 100x100 size: 360x400 color: silver
		draw: [
			dummy draw contents
		]
	]

	played-move-canvas: make face! [
		type: 'base text: "" offset: 10x10 size: 360x400 color: none
		draw: copy []
	]

	hints-canvas: make face! [
		type: 'base text: "" offset: 10x10 size: 360x400 color: none
		draw: copy []
	]
	
	message-text: make face! [
		type: 'text text: "It is your move" offset: 10x415 size: 300x25
	]
	
	make face! [ ; Take back button
		type: 'button text: "take back" offset: 290x415 size: 80x24
		actors: object [
			on-click: func [face [object!] event [event!]][
				print "take back code"
			]
		]
	]

	make face! [ ; New game as Red button
		type: 'button text: "New Game (Red)" offset: 10x465 size: 145x24
		actors: object [
			on-click: func [face [object!] event [event!]][
				print "New game as Red player code"
				; new-game-as RED-0
			]
		]
	]
	
	make face! [ ; New game as Black button
		type: 'button text: "New Game (Black)" offset: 160x465 size: 145x24
		actors: object [
			on-click: func [face [object!] event [event!]][
				print "New game as Black player code"
				;new-game-as BLACK-1
			]
		]
	]	
		
	make face! [ ; Quit button
		type: 'button text: "Stop" offset: 310x465 size: 60x24
		actors: object [
			on-click: func [face [object!] event [event!]][
				print "calling unview"
				unview/all
			]
		]
	]

	piece-panel: make face! [
		type:	'panel
;		type:	'base
		offset: 0x0
		size:	0x0
		color:  none
		pane:	reduce [ 
			black-king
			black-advisor-1
			black-advisor-2
			black-elephant-1
			black-elephant-2
			black-horse-1
			black-horse-2
			black-chariot-1
			black-chariot-2
			black-canon-1
			black-canon-2
			black-pawn-1
			black-pawn-2
			black-pawn-3
			black-pawn-4
			black-pawn-5

			white-king
			white-advisor-1
			white-advisor-2
			white-elephant-1
			white-elephant-2
			white-horse-1
			white-horse-2
			white-chariot-1
			white-chariot-2
			white-canon-1
			white-canon-2
			white-pawn-1
			white-pawn-2
			white-pawn-3
			white-pawn-4
			white-pawn-5
		]
	]
	
]

; Set canvas size (360x400)
canvas/size/1: 2 * margin-board + ( 8 * field-width )
canvas/size/2: 2 * margin-board + ( 9 * field-height )

; Set the pane size for the piece-panel
;piece-panel/size: canvas/size + canvas-offset

; Corrections on canvas offset
canvas/offset: canvas-offset
played-move-canvas/offset: canvas-offset
hints-canvas/offset: canvas-offset
;piece-panel/offset: canvas-offset

; Start drawing board on the canvas
canvas/draw: [
	line-cap round
	pen black
]

; Draw outline
p1: p2: p3: p4: 0x0
p1/1: p1/2: p2/2: p4/1: margin-board
p2/1: p3/1: 8 * field-width  + margin-board
p3/2: p4/2: 9 * field-height + margin-board

append canvas/draw reduce ['line p1 p2 p3 p4 p1] 

; Draw top vertical lines
p1: p2: 0x0
p1/2: margin-board
p2/2: field-height * 4 + margin-board 

repeat count 7 [
	vert: count * field-height + margin-board
	p1/1: vert
	p2/1: vert
	append canvas/draw reduce ['line p1 p2] 
]

; Draw bottom vertical lines
p1: p2: 0x0
p1/2: 5 * field-height + margin-board ; 220
p2/2: 9 * field-height + margin-board ; 380

repeat count 7 [
	vert: count * field-height + margin-board
	p1/1: vert
	p2/1: vert
	append canvas/draw reduce ['line p1 p2] 
]

; Draw horizontal lines
p1: p2: 0x0
p1/1: margin-board
p2/1: field-width * 8 + margin-board

repeat count 3 [
	vert: count * field-height + margin-board
	p1/2: vert
	p2/2: vert
	append canvas/draw reduce ['line p1 p2] 
]

; We skip the river, this is done later in blue
repeat count 3 [
	vert: count + 5 * field-height + margin-board ;-- count + 5 is calculated first!
	p1/2: vert
	p2/2: vert
	append canvas/draw reduce ['line p1 p2] 
]

; Draw the dots
dot-size: 4
p1/1: p1/2: margin-board

append canvas/draw [
	fill-pen black
]

board-dots: [
	0x3 1x2 2x3 4x3 6x3 7x2 8x3
	0x6 1x7 2x6 4x6 6x6 7x7 8x6
]

foreach board-dot board-dots [
	append canvas/draw reduce [
		'circle board-dot * field-width + p1 dot-size
	]
]

; Draw the palace crosses
cross-points: [
	3x0 5x2
	5x0 3x2
	3x9 5x7
	5x9 3x7
]

foreach [p2 p3] cross-points [
	append canvas/draw reduce [
		'line p2 * field-width + p1 p3 * field-width + p1
	]
]

; Draw 'the river' in blue
append canvas/draw [
	pen blue
]

river-points: [
	0x4 8x4
	0x5 8x5
]

foreach [p2 p3] river-points [
	append canvas/draw reduce [
		'line p2 * field-width + p1 p3 * field-width + p1
	]
]

; board is ready

;dump-face win
view win
