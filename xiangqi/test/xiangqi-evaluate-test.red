Red [
	"Test position evaluating for the game of xiangqi aka Chinese Chess"
	filename: %xiangqi-evaluate-test.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "21-Feb-2015"
	red-version: "Needs Red 0.5.0"
]

#include %../xiangqi-common.red
#include %../xiangqi-evaluate.red

init-evaluate-test: func [] [
	testname: "Evaluate Test"
	evaluate-test-results: 0
	evaluate-tests: 0
]

evaluate-result: func [
	testresult [logic! integer!]
][
	evaluate-tests: evaluate-tests + 1

	either expected-result = testresult [
		print ["test " evaluate-tests " success" expected-result "equals" testresult]
		evaluate-test-results: evaluate-test-results + 1
	][
		print ["test " evaluate-tests " failed"  expected-result "not equals" testresult]
	]
;	if all [any [	testresult <> expected-result]
;			any [	debug
;					report-info]][
;		print ["Reason: " info-area/code " " info-area/description]
;	]
;	init-info-area
]

conclude-test: function [
][
	print ["Test " testname "ended."]
	print ["Tests performed:" evaluate-tests]
	print ["Successes:" evaluate-test-results]
	print ["Failed tests:" evaluate-tests - evaluate-test-results ]
	
]

; Calling the function to be tested
comment {
evaluate-board: function [
	"Simple evaluation routine for the entire board"
	board [block!]
	return: [integer!]
}

init-evaluate-test

;********************************
; Tests with expected result true
;********************************
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

expected-result: 0
;print evaluate-board play-board
evaluate-result evaluate-board play-board
play-board: [
  8   0   0   0   2   0   3   0   0   9
 16   0   4   0   0   0   0   5   0  17
 32   0   0   2   0   0   3   0   0  33
 64   0   0   0   0   0   0   0   0  65
128   0   0   2   0   0   3   0   0 129
 64   0   0   0   0   0   0   0   0  65
 32   0   0   2   0   0   3   0   0  33
 16   0   4   0   0   0   0   5   0  17
  8   0   0   2   0   0   3   0   0   9
]
expected-result: 2
;print evaluate-board play-board
evaluate-result evaluate-board play-board

; exchange the canon for the horse
play-board: [
  8   0   0   2   0   0   3   0   0   0
 16   0   0   0   0   0   0   5   0   9
 32   0   0   2   0   0   3   0   0  33
 64   0   0   0   0   0   0   0   0  65
128   0   0   2   0   0   3   0   0 129
 64   0   0   0   0   0   0   0   0  65
 32   0   0   2   0   0   3   0   0  33
 16   0   4   0   0   0   0   5   0  17
  8   0   0   2   0   0   3   0   0   9
]
expected-result: -31
;print evaluate-board play-board
evaluate-result evaluate-board play-board

;
; Add more tests here (3+)
print "start-board"
print evaluate-board start-board
print "play-board"
print form play-board
print evaluate-board play-board

print "2 on 39"
play-board: [
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   2   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0  
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
]
print form play-board
print evaluate-board play-board

print "3 on 39"
play-board: [
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   3   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0  
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
]
print form play-board
print evaluate-board play-board

print "2 on 32"
play-board: [
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   2   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0  
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
]
print form play-board
print evaluate-board play-board

print "3 on 32"
play-board: [
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   3   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0  
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
]
print form play-board
print evaluate-board play-board

conclude-test

comment {
Testresults:

}
