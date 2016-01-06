Red [
	"Playing Xiangqi in Red with simple GUI"
	filename: %xiangqi-board.red
	author:   "Arnold van Hofwegen"
	version:  0.6.0
	date:     "06-Jan-2016"
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

;-- Import some xiangqi programs ----

; Common definitions
#include %xiangqi-common.red

; Move generation
#include %xiangqi-move-common.red
#include %xiangqi-moves.red

; Notation conversion and conversion between board and screen values of fields
#include %xiangqi-convertions.red
#include %utils/red-found.red

; Source for determining the best move
; Position evaluation
#include %xiangqi-evaluate.red

; Hash calculations 
#include %xiangqi-hash.red

; Opening book information
#include %xiangqi-open.red

; Calculate the best move using a PVS like algorithm
#include %xiangqi-best-move.red

;-- Declare some move variables ----
move-list:	copy []
play-board:	copy start-board
move-list:	make-move-list play-board 0
play-moves:	display-moves-list move-list
played-moves-list: copy []

computer-has: BLACK-1
color-to-move: RED-0

reversed-board?: false

search-depth: 2

; turn on/off opening book
in-opening-book: true

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

move-indicator-size: 0x0
move-indicator-size: half-image-size + 5x5

drag-saved-offset: 0x0
save-from-xy: 0x0

set-save-from-xy: func [
	pair [pair!]
][
	save-from-xy: pair
]

get-save-from-xy: func [
][
	save-from-xy
]

set-drag-saved-offset: func [
	pair [pair!]
][
	drag-saved-offset: pair
]

get-drag-saved-offset: func [
][
	drag-saved-offset
]

create-played-move-canvas: func [
	move-block [block!]
	return: [block!]
	/local pmc [block!]
	place [pair!]
][
	pmc: copy []
	pmc: copy either RED-0 = computer-has [
		[pen red fill-pen 255.0.0.205]
	][
		[pen blue fill-pen 0.0.255.205]
	]
	place: move-block/1 * field-size + margins
	append pmc 'circle
	append pmc place
	append pmc half-image-size/1 + 5
	place: move-block/2 * field-size + margins
	append pmc 'circle
	append pmc place
	pmc: append pmc half-image-size/1 + 5
]

play-computer-move: func [
	/local 
		computer-move [block!]
		move-pairs [block!]
][
	; set message to computing move now
	set-message computer-has	
	
	; set move pictogram to computer
	change-move-indication computer-has
	
	; compute the move
	computer-move: get-computer-move
	
	; Play the move on the GUI, includes add move to the played moves list
	; and also includes play the move on the play-board block
	move-pairs: integer-move-to-GUI-move computer-move
	
	gui-play-move/computer move-pairs/1 move-pairs/2
	; show last move
	played-move-canvas/draw: create-played-move-canvas move-pairs
	show played-move-canvas

	; make new play-moves list
	move-list: make-move-list play-board ( 1 - computer-has )
	play-moves: display-moves-list move-list

	; reset message
	set-message 1 - computer-has
	; set move pictogram to player
	change-move-indication 1 - computer-has
]

;-- functions for the buttons ----
new-game-as: func [
	player-color [integer!]
][
	color-to-move: RED-0
	
	play-board: copy start-board
	move-list: make-move-list play-board color-to-move
	play-moves: display-moves-list move-list

	computer-has: either player-color = RED-0 [BLACK-1][RED-0]
	
	played-moves-list: copy []
	
	;replace all pieces on the board
	board-pieces: copy all-pieces
	
	reversed-board?: false
	
	if computer-has = RED-0 [
		reversed-board?: true
		rotate-board-pieces
	]
	
	reset-pieces-faces
	
	if computer-has = color-to-move [
		play-computer-move
	]
]

get-computer-move: func [
	return: [block!]
	/local computer-move [block!]
][
	computer-move: copy []
	computer-move: iterative-deepening-search play-board computer-has search-depth
	; computer move is now a block of 2 integers (from opening book) or a 
	; complete move block with all move information.
]

integer-move-to-GUI-move: function [
	move-block [block!]
	return: [block!]
	/local
		out [block!]
][
	out: copy [1 2]
	either 2 = length? move-block [
		out/1: field-to-xy move-block/1
		out/2: field-to-xy move-block/2
	][
		out/1: field-to-xy move-block/2
		out/2: field-to-xy move-block/3
	]
	out
]

change-move-indication: func [
	to-color [integer!]
][
	either BLACK-1 = to-color [
		red-to-move/size: 0x0
		black-to-move/size: move-indicator-size
	][
		red-to-move/size: move-indicator-size
		black-to-move/size: 0x0
	]
	show red-to-move
	show black-to-move
]

text-move-for-computer: "Computing move now..."
text-move-for-player:   "Your move"

set-message: func [
	turn [integer!]
][
	message-text/text: either turn = computer-has [
		text-move-for-computer
	][
		text-move-for-player
	]
	show message-text
]

show-hide-piece-face: func [
	piece-info [string! pair!]
	show? [logic!]
	/local
		reset-piece [block!]
	    reset-piece-string [string!]
		piece-name [string!] 
		piece-offset [pair!]
][
	board-pieces: head board-pieces
	
	piece-name: either string! = type? piece-info [ ; using id
		first back find board-pieces piece-info
	][ ; using location
		first back back find board-pieces piece-info
	]

	board-pieces: head board-pieces
	board-pieces: next next find board-pieces piece-name
	board-pieces/1: -1 * board-pieces/1 
	either show? [ ; works well but not for 0x0 so we (dirty) hack this situation
		if -9x-9 = board-pieces/1 [board-pieces/1: 0x0]
	][
		if 0x0 = board-pieces/1 [board-pieces/1: -9x-9]
	]
	board-pieces: head board-pieces
	
	reset-piece-string: copy ""
	append reset-piece-string piece-name
	append reset-piece-string "/size: " 
	append reset-piece-string either show? [image-size]["0x0"]

	reset-piece: load reset-piece-string
	do reset-piece

	; Just to be sure, setting at beginning of the series
	board-pieces: head board-pieces
]

gui-play-move: func [
	move-from [pair!]
	move-to [pair!]
	/computer
	/local field-from [integer!]
		field-to [integer!]
		piece [integer!]
		capture-value [integer!]
		move [block!]
		piece-id [string!]
		computer-offset [pair!]
][
	field-from: xy-to-field move-from
	field-to:   xy-to-field move-to
	piece: play-board/:field-from
	capture-value: play-board/:field-to
	move: copy []
	move: rejoin [piece field-from field-to capture-value]
	if 0 < capture-value [
		; get face/id from piece
		board-pieces: head board-pieces
		back find board-pieces move-to
		piece-id: board-pieces/1
		board-pieces: head board-pieces
		append move piece-id
		show-hide-piece-face move-to no ; false means to hide
	]
	; set grid location of moving piece to new position
	board-pieces: head board-pieces
	board-pieces: back find board-pieces move-from
	board-pieces/2: move-to
	if computer [
		; adjust face/offset of played piece
		foreach computerpiece piece-panel/pane [
			if computerpiece/id = board-pieces/1 [
				computer-offset: left-upper-corner/offset + margins + ( field-size * move-to ) + half-image-size - half-field
				computerpiece/offset: computer-offset
			]
		]
	]
	board-pieces: head board-pieces
	; append move to the list	
	append/only played-moves-list move
	play-board/:field-to: piece
	play-board/:field-from: 0
]

gui-undo-one-ply: func [
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
		; show this image 
		show-hide-piece-face move/5 yes 
	]
	; now remove the last move from the list of played moves
	take/last played-moves-list	
]

take-back-move: func [
][
	if 0 = length? played-moves-list [ return 0 ]
	;undo last move by computer
	gui-undo-one-ply
	either 0 < length? played-moves-list [
		;undo last move by player
		gui-undo-one-ply
	][
		; if computer is red/white play a new move
		change-move-indication RED-0
		if RED-0 = computer-has [
			; compute the best move (again)
		]
	]
	return 0
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

; function to go from face/offset to x y coordinates. Helper function for actors on pieces
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

; Pieces to be placed on the canvas
; The offset is used as grid location of the piece. 
; It is also used to compute the piece face/offset. 
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
get-board-pieces: does [
	board-pieces
]

;-- actors

piece-actors: object [
		on-over: function [face [object!] event [event!]][
;			print ["Event over" event/offset event/away?]
			if not face/drag [  ;do not recompute when dragging a piece around
				either event/away? [
					hints-canvas/draw: copy []
				][
					relative-offset: 0x0
					relative-offset: face/offset - left-upper-corner/offset - canvas/offset - margins + field-size
					fotxy: face-offset-to-xy relative-offset
					set-save-from-xy fotxy
					fotxy-field: xy-to-field fotxy
;					if any [0 > fotxy/1
;							0 > fotxy/2
;							8 < fotxy/1
;							9 < fotxy/2 ][ ;-- do not test drops off board yet
						mydestinations: select play-moves fotxy-field
						face/dest: mydestinations
						if not empty? mydestinations [
							hints-block: either computer-has = RED-0 [
								copy [pen blue fill-pen 0.0.255.205 ]
							][
								copy [pen red  fill-pen 255.0.0.205 ]
							]
							foreach dest mydestinations [
								place: dest * field-size + half-image-size + 5x5
								append hints-block 'circle
								append hints-block place
								append hints-block half-image-size/1 + 5
							]
							; for debug purposes
							;probe hints-block
							hints-canvas/draw: copy hints-block
							show hints-canvas
						]
;					]
				]
			]
		]
		
		on-drag-start: function [face [object!] event [event!]][
;			print ["drag starts at" event/offset face/offset]
			set-drag-saved-offset face/offset
			; now hide the last move
			played-move-canvas/draw: copy []
			face/drag: true
			; save from field location
			;relative-offset: 0x0
			;relative-offset: face/offset - left-upper-corner/offset - canvas/offset - margins + field-size
			;save-from-xy: face-offset-to-xy relative-offset
			; Make sure the piece goes over all others
			; Only bring to top if it is not already on top
			if not piece-top-z-order? face/id [
				bring-to-top face
				set-piece-top-z-order face-id-to-piece-name face/id
			]
		]
		
		on-drop: function [face [object!] event [event!]][
;			print ["dropping" event/offset face/offset]
			face/drag: false
			either empty? face/dest [
				face/offset: get-drag-saved-offset
			][
				relative-offset: 0x0
				relative-offset: face/offset - left-upper-corner/offset - correction-offset + half-field
				
				either any [0 > relative-offset/1 
							0 > relative-offset/2][
					face/offset: get-drag-saved-offset
				][
					drop-fotxy: face-offset-to-xy relative-offset
					either any [ 8 < drop-fotxy/1
							 	 9 < drop-fotxy/2 ][
						face/offset: get-drag-saved-offset
					][ 
						either found? find face/dest drop-fotxy [
							; here an allowed move was performed
							; set new location for the moving piece in the board-pieces block
							; add players move to the played-move-list
							; perform the players move on the play-board block
							gui-play-move get-save-from-xy drop-fotxy						
							; set the piece face/offset to the new location (exact placing on grid)
							drop-fotxy: drop-fotxy * field-size + half-image-size - half-field
							; Because win/offset is on the outside of the window, generally a difference of 8x30 or 8x50
							face/offset: left-upper-corner/offset + margins + drop-fotxy

							; and get the return move from the computer
							play-computer-move
						][
							face/offset: get-drag-saved-offset
						]
					]
				]
			]

			face/drag: false
			hints-canvas/draw: copy []
		]
]

rotated-board-position: function [
	position [pair!]
	return: [pair!]
	/local out [pair!]
][
	out: 8x9 - position
]

rotate-board-pieces: func [
	/local
		p [string!] i [string!] t [string!] a [string!] c [string!]
		o [pair!]
][
	foreach [p i o t a c] board-pieces [
		o: rotated-board-position o
	]
]

; reset the board and place the pieces 
reset-pieces-faces: func [
	/local 
		reset-piece [block!]
	    reset-piece-string [string!]
		p [string!] i [string!] t [string!] a [string!] c [string!]
		o [pair!]
		piece-offset [pair!]
][
	;board-pieces: copy all-pieces
	foreach [p i o t a c] board-pieces [
		piece-offset: 0x0
		piece-offset: o * field-size + correction-offset
		reset-piece-string: copy ""
		reset-piece-string: rejoin [p "/offset: " piece-offset " " p "/size: " image-size]
		reset-piece: load reset-piece-string
		do reset-piece
	]
]

image-path: %images/

; Create the face specs dynamically here
make-piece-faces: func [
	/local 
		declare-piece [block!]
		declare-piece-string [string!]
		p [string!] i [string!] t [string!] a [string!] c [string!]
		o [pair!]
		piece-offset [pair!]
][
	foreach [p i o t a c] board-pieces [
		; Here we declare piece image and other attributes
		declare-piece: copy []
		declare-piece-string: copy ""

		declare-piece-string: rejoin [p ": make face! [" newline "type: 'base offset: "]
		piece-offset: 0x0
		piece-offset: o * field-size + correction-offset
		declare-piece-string: rejoin [
			declare-piece-string piece-offset 
		    " size: " image-size newline 
		    "image: load %" image-path "Xiangqi_"
			t "_" a c ".png" newline 
			"	options: [drag-on: 'down]" newline
			{	id: "} i {"} newline
			"	actors: piece-actors" newline
			" dest: copy [] drag: false ]"
		]
		
		; for debug purposes
		;print declare-piece-string 
		
		; perform the declaration 		
		declare-piece: load declare-piece-string
		do declare-piece		

	]	; end foreach piece
	
	; for debug purposes
	;print declare-piece-string
]

make-piece-faces 

;-- Make sure dragged piece moves over other pieces while dragging
start-pieces-pane-block: copy [
	black-king	black-advisor-1	black-advisor-2	black-elephant-1	black-elephant-2
	black-horse-1	black-horse-2	black-chariot-1	black-chariot-2	black-canon-1	black-canon-2
	black-pawn-1	black-pawn-2	black-pawn-3	black-pawn-4	black-pawn-5

	white-king	white-advisor-1	white-advisor-2	white-elephant-1	white-elephant-2
	white-horse-1	white-horse-2	white-chariot-1	white-chariot-2	white-canon-1	white-canon-2
	white-pawn-1	white-pawn-2	white-pawn-3	white-pawn-4	white-pawn-5
]

pieces-pane-block: copy []

init-pieces-pane-block: func [
][ 
	pieces-pane-block: copy start-pieces-pane-block
]

init-pieces-pane-block

piece-top-z-order: copy ""

set-piece-top-z-order: func [
	name [string!]
][
	piece-top-z-order: name
]

set-piece-top-z-order "white-pawn-5"

piece-top-z-order?: func [
	name [string!]
	return: [logic!]
][
	either name = piece-top-z-order [true][false]
]

face-id-to-piece-name: func [ 
	face-id [string!]
	return: [string!]
][
	board-pieces: head board-pieces
	first back find board-pieces face-id
]

bring-to-top: func [item /local parent pane] [
	if all [
		parent: item/parent
		block? pane: parent/pane
	][
		swap find pane item back tail pane ;<--- it's possible to drag with this
		show parent
	]
]

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
				print "take back code to be added"
			]
		]
	]

	make face! [ ; New game as Red button
		type: 'button text: "New Game (Red)" offset: 10x465 size: 145x24
		actors: object [
			on-click: func [face [object!] event [event!]][
				print "New game as Red player code to be added"
				; new-game-as RED-0
			]
		]
	]
	
	make face! [ ; New game as Black button
		type: 'button text: "New Game (Black)" offset: 160x465 size: 145x24
		actors: object [
			on-click: func [face [object!] event [event!]][
				print "New game as Black player code to be added"
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
		offset: 0x0
		size:	0x0
		color:  none
		pane:	reduce pieces-pane-block
	]
	
]

; Set canvas size (360x400)
canvas/size/1: 2 * margin-board + ( 8 * field-width )
canvas/size/2: 2 * margin-board + ( 9 * field-height )

; Corrections on canvas offset
canvas/offset: canvas-offset
played-move-canvas/offset: canvas-offset
hints-canvas/offset: canvas-offset

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
; Drawing the board is finished here

; Now show and run the application
;dump-face win
view win
