Red [
	"Add special functions for xiangqi aka Chinese Chess while Red is in development"
	filename: %xiangqi-influence-test.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "23-Feb-2015"
	red-version: "Needs Red 0.5.0"
]
comment {
 Hopefully this file becomes empty one day.
}

; This file provides multi case for switch
#include %red-multi-switch.red

; Multi switch simple case replacement did not compile using 'FOUND?
#include %red-element-in-collection.red

; New 'FOUND? replacement
#include %red-found.red

; Because rejoin is so much nicer than all appends
; Same Rejoin function has been added in commit 6526 on 7 july 2016
;#include %red-rejoin.red
