Red [
	"Common definitions for the game of xiangqi aka Chinese Chess"
	filename: %xiangqi-common.red
	author:   "Arnold van Hofwegen"
	version:  0.2
	date:     "13-Aug-2015"
]

; Temporary helper functions while Red is in development
#include %utils/xiangqi-helper-functions.red

;********************
; General
;********************

;**********************************************************
; The color representing red/white is 0 black/blue is 1
; For GUI just RED and BLACK conflicted with the predefined
; colors (255.0.0 and 0.0.0), so redefined here
;**********************************************************
RED-0: 0
BLACK-1: 1

;********************
; Pieces
;********************
BLACK-PAWN:      BLACK-1 + RED-PAWN:      PAWN:       2
BLACK-CANON:     BLACK-1 + RED-CANON:     CANON:      4
BLACK-CHARIOT:   BLACK-1 + RED-CHARIOT:   CHARIOT:    8
BLACK-KNIGHT:    BLACK-1 + RED-KNIGHT:    KNIGHT:    16
BLACK-ELEPHANT:  BLACK-1 + RED-ELEPHANT:  ELEPHANT:  32
BLACK-ADVISOR:   BLACK-1 + RED-ADVISOR:   ADVISOR:   64
BLACK-KING:      BLACK-1 + RED-KING:      KING:     128
ROOK: 8

;********************
; The board
;********************
empty-board: [
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
]

start-board: [
  8   0   0   2   0   0   3   0   0   9
 16   0   4   0   0   0   0   5   0  17
 32   0   0   2   0   0   3   0   0  33
 64   0   0   0   0   0   0   0   0  65
128   0   0   2   0   0   3   0   0 129
 64   0   0   0   0   0   0   0   0  65
 32   0   0   2   0   0   3   0   0  33
 16   0   4   0   0   0   0   5   0  17
  8   0   0   2   0   0   3   0   0   9
]

;********************
; Evaluation
;********************
;********************
; Piece values
;********************
comment {
Piece values and position tables are from ELP document
http://www.csie.ndhu.edu.tw/~sjyen/Papers/2004CCC.pdf
}
VALUE-KING:     9000
VALUE-ADVISOR:  120
VALUE-ELEPHANT: 120
VALUE-KNIGHT:   270
VALUE-CHARIOT:  600
VALUE-CANON:    285
VALUE-PAWN:      30 ; relative values are influencenced by position tables

;********************
; Position tables
;********************
comment {
Only position tables for white/red are needed, the ones for blue/black are implicit because of symmetry.
No table for Elephant, Advisor and King needed, these have limited places to go and must go where needed.
}

position-values-rook: [
 -2   8   4   6  12  12  12  12  16  14
 10   4   8  10  16  14  18  12  20  14
  6   8   6   8  14  12  14  12  18  12
 14  16  14  14  20  18  22  18  24  18
 12   8  12  14  20  18  22  18  26  16
 14  16  14  14  20  18  22  18  24  18
  6   8   6   8  14  12  14  12  18  12
 10   4   8  10  16  14  18  12  20  14
 -2   8   4   6  12  12  12  12  16  14
]

position-values-knight: [
  0   0   4   2   4   6   8  12   4   4
 -4   2   2   6  12  16  24  14  10   8
  0   4   8   8  16  14  18  16  28  16
  0   4   8   6  14  18  24  20  16  12
  0  -2   4  10  12  16  20  18   8   4
  0   4   8   6  14  18  24  20  16  12
  0   4   8   8  16  14  18  16  28  16
 -4   2   2   6  12  16  24  14  10   8
  0   0   4   2   4   6   8  12   4   4
]

position-values-cannon: [
  0   0   4   0  -2   0   0   2   2   6
  0   2   0   0   0   0   0   2   2   4
  2   4   8   0   4   0  -2   0   0   0
  6   6   6   2   2   2   4 -10  -4 -10
  6   6  10   4   6   8  10  -8 -14 -12
  6   6   6   2   2   2   4 -10  -4 -10
  2   4   8   0   4   0  -2   0   0   0
  0   2   0   0   0   0   0   2   2   4
  0   0   4   0  -2   0   0   2   2   6
]

position-values-pawn: [
  0   0   0   0   2   6  10  14  18   0
  0   0   0   0   0  12  20  26  36   3
  0   0   0  -2   8  18  30  42  56   6
  0   0   0   0   0  18  34  60  80   9
  0   0   0   4   8  20  40  80 120  12
  0   0   0   0   0  18  34  60  80   9
  0   0   0  -2   8  18  30  42  56   6
  0   0   0   0   0  12  20  26  36   3
  0   0   0   0   2   6  10  14  18   0
]

;********************
; Best move
;********************
;********************
; Search depth
;********************
MAX-DEPTH: 4
search-depth: MAX-DEPTH

init-search-depth: func [
	depth [integer!]
][
	if depth > MAX-DEPTH [depth: MAX-DEPTH]
	search-depth: depth
]

init-search-depth max-depth

;********************
; Evaluation
;********************
MINUS-INFINITY: negate INFINITY: 99999
alpha: MINUS-INFINITY
beta:  INFINITY

;*******************************
; Various best move and gameplay
;*******************************
in-opening-book?: true

time-limit: false ; time limited gameplay
time-moves: 40
time-total: 3600 ; 60 minutes in seconds, 7200 is 120 minutes
time-per-move: time-total / time-moves ; 90 seconds per move

winning-moves-found?: single-playable-move?: false
all-moves-lose?: max-calculation-time-used?: false
