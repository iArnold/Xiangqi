Red [
	"Test iterative deepening search for the game of xiangqi aka Chinese Chess"
	filename: %xiangqi-best-move-test.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "19-Mrt-2015"
	red-version: "Needs Red 0.5.0"
]

#include %../utils/xiangqi-helper-functions.red
#include %../xiangqi-common.red
#include %../xiangqi-debug-log.red
#include %../xiangqi-move-common.red 
#include %../xiangqi-evaluate.red 
#include %../xiangqi-moves.red
#include %../xiangqi-best-move.red
#include %../xiangqi-open.red
#include %../xiangqi-hash.red
#include %../xiangqi-convertions.red 
#include %../../bind/C-library/input-output.red

set-logging-values true
set-logging-values/list true
set-logging-values/board true
set-logging-values/moves true

;play-board: copy start-board
;play-board: [
;  0   0   0   0   0   0   0   0   0   0
;  0   0   0   0   0   0   0   0   0   0
;  0   0   0   0   0   0   0   0   0   0
;  8   0   0   0   0   0   0   0   0   0
;128   0   0   0   0   0   0   0   0   0
;  0   0   0   0   0   0   0   0   0 129
;  8   0   0   2   0   0   0   0   0   0
;  0   0   0   0   0   0   0   0   0   0
;  0   0   0   0   0   0   0   0   0   0
;]
;best-move-is: iterative-deepening-search play-board 0 2

play-board: [
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  8   0   0   0   0   0   0   0   0   0
128   0   0   0   0   0   0   0  65   0
  0   0   0   0   0   0   0   0   0 129
  8   0   0   2   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
]

probe play-board
print "Call IDS:"
;best-move-is: iterative-deepening-search play-board 0 1
best-move-is: iterative-deepening-search play-board 1 3
;principal-variation-search in-board color alpha beta depth variant true
;principal-variation-search play-board 1 MINUS-INFINITY INFINITY 2 (copy []) true
;best-move-is: iterative-deepening-search play-board 0 3

print "ids-move-list:"
probe ids-move-list
print "best found move is"
print best-move-is
print "Log-data:"

reversed-play-board: [
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   9
  0  64   0   0   0   0   0   0   0 129
128   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   3   0   0   9
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
]
print "reversed values white to play"
append log-data newline
append log-data "*******************************"
append log-data newline
append log-data "*reversed values white to play*"
append log-data newline
append log-data "*******************************"
append log-data newline

best-move-is: iterative-deepening-search reversed-play-board 0 3

print "ids-move-list:"
probe ids-move-list
print "best found move is"
print best-move-is

write %xiangqi-log.log log-data

print "End of testprogram xiangqi-best-move-test.red"