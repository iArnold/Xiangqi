Red [
	"Definitions for debugging the game of xiangqi aka Chinese Chess"
	filename: %xiangqi-debug-log.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "13-Aug-2015"
]

;************************************************************
; Variables and functions to facilitate debugging and logging
;************************************************************
; Sometimes it is needed to get some reporting on program state, debugging, 
; knowing the moves and various values in the decision making process
; This can use some extra attention to unify various approaches.

;**********
; Debugging
;**********
debug: true			; turn debugging on 
debug-level: 0      ;   ( > 0 ) and off ( 0 )

init-debug: func [
	/start
	/stop
][
	debug: false
	if start [debug: true]
]

;********
; Logging
;********
log-data: copy ""

add-log-data: func [
	data [string!]
][  
	;print ["logging : " data]
	append log-data data
	append log-data newline
]

logging-values: object [
	logging-on: false
	list: false
	board: false
	variant: false
	moves: false
]

logging: func [       ; logging on or off?
	/list
	/board
	/variant
	/moves
	return: [logic!]
][
	if list    [return logging-values/list]
	if board   [return logging-values/board]
	if variant [return logging-values/variant]
	if moves   [return logging-values/moves]
	return logging-values/logging-on
]

set-logging-values: func [
	set-value [logic!]
	/list
	/board
	/variant
	/moves
	/set-all
][
	if any [set-all
			list    ][logging-values/list: set-value]
	if any [set-all
			board   ][logging-values/board: set-value]
	if any [set-all
			moves   ][logging-values/moves: set-value]
	if any [set-all
			variant ][logging-values/variant: set-value]
	if any [set-all
			not any [list
					 board
					 moves
					 variant]][logging-values/logging-on: set-value]
]

;**********
; Reporting
;**********
reporting: off      ;
report-info: true   ; 

info-area: object [
	code: description: none 
]

init-info-area: does [
	info-area/code: none
	info-area/description: none
]
