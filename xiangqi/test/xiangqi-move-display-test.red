Red [
	"Test generation of moves for the game of xiangqi aka Chinese Chess"
	filename: %xiangqi-move-display-test.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "25-Sep-2015"
	red-version: "Needs Red 0.5.0"
]
move-list: copy []
#include %../utils/xiangqi-helper-functions.red
#include %../xiangqi-common.red
#include %../xiangqi-move-common.red 
#include %../xiangqi-evaluate.red 
#include %../xiangqi-hash.red
#include %../xiangqi-moves.red
#include %../xiangqi-convertions.red


;*******************************************
; Tests with expected result generated moves
;*******************************************
; test 1, the start position
play-board: [
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

; Test 1
white-moves: copy []
black-moves: copy []

white-moves: make-move-list play-board 0
probe white-moves
probe my-display-moves: display-moves-list white-moves

black-moves: make-move-list play-board 1
probe black-moves
probe my-display-moves: display-moves-list black-moves
