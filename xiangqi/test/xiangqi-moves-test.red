Red [
	"Test generation of moves for the game of xiangqi aka Chinese Chess"
	filename: %xiangqi-moves-test.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "24-Feb-2015"
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

init-debug/stop

init-moves-test: does [
	testname: "Moves Generating"
	moves-test-results: 0
	moves-tests: 0
]

moves-result: func [
	testresult [block!]
	/local blocks-are-equal [logic!]
	length-testresult [integer!]
	length-expected-result [integer!]
	formed-move [string!]
	formed-test-move [string!]
	;molded-moves [string!]
	;molded-test-moves [string!]
][
	moves-tests: moves-tests + 1
	blocks-are-equal: true
	; this differs from the original because it is not so simple to compare the generated moves block with the printed / probed version
	length-testresult: length? testresult
	length-expected-result: length? expected-result
	if length-expected-result <> length-testresult [
		blocks-are-equal: false
		print ["lengths unequal, expected:" length-expected-result " testresult:" length-testresult]
	]
	if blocks-are-equal [
comment { ; does not work fine with mold or mold/all
		molded-test-moves: mold/all testresult
		molded-moves: mold/all expected-result
		if molded-moves <> molded-test-moves [
			blocks-are-equal: false
			print ["move unequal, expected:" molded-moves " testresult:" molded-test-moves]
		]
}
		count: 1
		foreach move expected-result [
			test-move: first testresult
			formed-move: form move
			formed-test-move: form test-move
			;if move <> test-move [
			if formed-move <> formed-test-move [
				blocks-are-equal: false
				print ["move " count " unequal, expected:" move " testresult:" test-move]
				probe move
				probe test-move
			]
			testresult: next testresult
			count: count + 1
		]
	]
	testresult: head testresult
	;either expected-result = testresult [
	either blocks-are-equal [
		print ["test " moves-tests " success"]
		;print ["test " moves-tests " success" newline 
		;	expected-result newline "equals" newline testresult]
		moves-test-results: moves-test-results + 1
	][
		print ["test " moves-tests " failed" newline 
			expected-result newline "not equals" newline testresult]
	]
]

conclude-test: function [
][
	print ["Test " testname "ended."]
	print ["Tests performed:" moves-tests]
	print ["Successes:" moves-test-results]
	print ["Failed tests:" moves-tests - moves-test-results ]
	
]
; Calling the function to be tested
comment {
make-move-list: func [
	in-board [block!]
	color [integer!]
	return: [block!]
}

init-moves-test

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
expected-result: [[8 1 2 0 false 10][8 1 3 0 false 6][2 4 5 0 false 2][16 11 3 0 false 8][16 11 23 0 false 12][4 13 3 0 false 4][4 13 23 0 false 8][4 13 33 0 false 6][4 13 43 0 false 10][4 13 53 0 false 6][4 13 63 0 false 8][4 13 14 0 false 0][4 13 15 0 false 0][4 13 16 0 false 0][4 13 17 0 false 0][4 13 20 17 false 270][4 13 12 0 false 2][32 21 3 0 false 0][32 21 43 0 false 0][2 24 25 0 false 10][64 31 42 0 false 0][128 41 42 0 false 0][2 44 45 0 false 4][64 51 42 0 false 0][32 61 43 0 false 0][32 61 83 0 false 0][2 64 65 0 false 10][16 71 63 0 false 12][16 71 83 0 false 8][4 73 63 0 false 8][4 73 53 0 false 6][4 73 43 0 false 10][4 73 33 0 false 6][4 73 23 0 false 8][4 73 83 0 false 4][4 73 74 0 false 0][4 73 75 0 false 0][4 73 76 0 false 0][4 73 77 0 false 0][4 73 80 17 false 270][4 73 72 0 false 2][8 81 82 0 false 10][8 81 83 0 false 6][2 84 85 0 false 2]]
;probe make-move-list play-board 0
moves-result make-move-list play-board 0

; Test 2
expected-result: [[3 7 6 0 false 2] [9 10 9 0 false 10] [9 10 8 0 false 6] [5 18 8 0 false 4] [5 18 28 0 false 8] [5 18 38 0 false 6] [5 18 48 0 false 10] [5 18 58 0 false 6] [5 18 68 0 false 8] [5 18 19 0 false 2] [5 18 17 0 false 0] [5 18 16 0 false 0] [5 18 15 0 false 0] [5 18 14 0 false 0] [5 18 11 16 false 270] [17 20 8 0 false 8] [17 20 28 0 false 12] [3 27 26 0 false 10] [33 30 8 0 false 0] [33 30 48 0 false 0] [65 40 49 0 false 0] [3 47 46 0 false 4] [129 50 49 0 false 0] [65 60 49 0 false 0] [3 67 66 0 false 10] [33 70 48 0 false 0] [33 70 88 0 false 0] [5 78 68 0 false 8] [5 78 58 0 false 6] [5 78 48 0 false 10] [5 78 38 0 false 6] [5 78 28 0 false 8] [5 78 88 0 false 4] [5 78 79 0 false 2] [5 78 77 0 false 0] [5 78 76 0 false 0] [5 78 75 0 false 0] [5 78 74 0 false 0] [5 78 71 16 false 270] [17 80 68 0 false 12] [17 80 88 0 false 8] [3 87 86 0 false 2] [9 90 89 0 false 10] [9 90 88 0 false 6]]
;probe make-move-list play-board 1
moves-result make-move-list play-board 1

; Test 3
play-board: [8 0 0 2 0 0 3 0 0 9 16 0 0 0 0 0 0 5 0 4 32 0 0 2 0 0 3 0 0 33 64 0 0 0 0 0 0 0 0 65 128 0 0 2 0 0 3 0 0 129 64 0 0 0 0 0 0 0 0 65 32 0 0 2 0 0 3 0 0 33 8 0 4 0 0 0 0 0 0 17 0 0 0 2 0 0 3 0 0 9]
expected-result: [[3 7 6 0 false 2] [9 10 20 4 false 301] [9 10 9 0 false 10] [9 10 8 0 false 6][5 18 8 0 false 4] [5 18 28 0 false 8] [5 18 38 0 false 6] [5 18 48 0 false 10][5 18 58 0 false 6] [5 18 68 0 false 8] [5 18 78 0 false 0] [5 18 88 0 false 4][5 18 19 0 false 2] [5 18 17 0 false 0] [5 18 16 0 false 0] [5 18 15 0 false 0][5 18 14 0 false 0] [5 18 13 0 false 2] [5 18 12 0 false 2] [3 27 26 0 false 10][3 47 46 0 false 4] [129 50 49 0 false 0] [65 60 49 0 false 0] [3 67 66 0 false 10] [33 70 48 0 false 0] [33 70 88 0 false 0] [17 80 68 0 false 12] [17 80 88 0 false 8] [3 87 86 0 false 2] [9 90 89 0 false 10] [9 90 88 0 false 6]]
;probe make-move-list play-board 1
moves-result make-move-list/capture play-board 1

; Test 4
print "Capturemoves"
; Same board as Test 3
expected-result: [[9 10 20 4 false 301]]
;probe make-move-list/capture play-board 1
moves-result make-move-list/capture play-board 1

; Add more tests here (5+)
;expected-result: [ paste the generated moves here ]
;probe make-move-list play-board 1
;moves-result make-move-list play-board 1
move-debug: true
play-board: [
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  8   0   0   0   0   0   0   0   0   0
128   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0 129
  8   0   0   2   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
]
;expected-result: [[3 7 6 0 false 2] [9 10 20 4 false 301] [9 10 9 0 false 10] [9 10 8 0 false 6][5 18 8 0 false 4] [5 18 28 0 false 8] [5 18 38 0 false 6] [5 18 48 0 false 10][5 18 58 0 false 6] [5 18 68 0 false 8] [5 18 78 0 false 0] [5 18 88 0 false 4][5 18 19 0 false 2] [5 18 17 0 false 0] [5 18 16 0 false 0] [5 18 15 0 false 0][5 18 14 0 false 0] [5 18 13 0 false 2] [5 18 12 0 false 2] [3 27 26 0 false 10][3 47 46 0 false 4] [129 50 49 0 false 0] [65 60 49 0 false 0] [3 67 66 0 false 10] [33 70 48 0 false 0] [33 70 88 0 false 0] [17 80 68 0 false 12] [17 80 88 0 false 8] [3 87 86 0 false 2] [9 90 89 0 false 10] [9 90 88 0 false 6]]
probe make-move-list play-board 0

play-board: [
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   8
128   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0 129
  8   0   0   2   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
]
probe make-move-list play-board 1

print "no moves for color 1?"
play-board: [
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  8   0   0   0   0   0   0   0   0   0
128   0   0   0   0   0   0   0   0   0
  8   0   0   0   0   0   0   0   0 129
  0   0   0   2   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
  0   0   0   0   0   0   0   0   0   0
]
probe make-move-list play-board 1


print "no moves for color 1!!"
play-board: [
0 0 0 2 0 0 3 0 0 9
8 0 0 0 0 0 0 0 0 17
32 0 0 5 0 0 3 0 0 33
64 0 0 0 0 0 0 0 0 65
128 0 0 2 0 4 4 0 0 129
64 0 0 0 0 0 0 0 0 65
32 0 0 0 0 0 3 0 0 33
8 0 0 0 0 0 0 0 0 17
8 0 0 2 0 0 3 0 0 9]
probe make-move-list play-board 1
; Conclude test
conclude-test

comment {
Expected results:
probe make-move-list play-board 0
[[8 1 2 0 false 10] [8 1 3 0 false 6] [2 4 5 0 false 2] [16 11 3 0 false 8] [16 11 23 0 false 12] [4 13 3 0 false 4] [4 13 23 0 false 8] [4 13 33 0 false 6] [4 13 43 0 false 10] [4 13 53 0 false 6] [4 13 63 0 false 8] [4 13 14 0 false 0] [4 13 15 0 false 0] [4 13 16 0 false 0] [4 13 17 0 false 0] [4 13 20 17 false 270] [4 13 12 0 false 2] [32 21 3 0 false 0] [32 21 43 0 false 0] [2 24 25 0 false 10] [64 31 42 0 false 0] [128 41 42 0 false 0] [2 44 45 0 false 4] [64 51 42 0 false 0] [32 61 43 0 false 0] [32 61 83 0 false 0] [2 64 65 0 false 10] [16 71 63 0 false 12] [16 71 83 0 false 8] [4 73 63 0 false 8] [4 73 53 0 false 6] [4 73 43 0 false 10] [4 73 33 0 false 6] [4 73 23 0 false 8] [4 73 83 0 false 4] [4 73 74 0 false 0] [4 73 75 0 false 0] [4 73 76 0 false 0] [4 73 77 0 false 0] [4 73 80 17 false 270] [4 73 72 0 false 2] [8 81 82 0 false 10] [8 81 83 0 false 6] [2 84 85 0 false 2]]

probe make-move-list play-board 1
[[3 7 6 0 false 2] [9 10 9 0 false 10] [9 10 8 0 false 6] [5 18 8 0 false 4] [5 18 28 0 false 8] [5 18 38 0 false 6] [5 18 48 0 false 10] [5 18 58 0 false 6] [5 18 68 0 false 8] [5 18 19 0 false 2] [5 18 17 0 false 0] [5 18 16 0 false 0] [5 18 15 0 false 0] [5 18 14 0 false 0] [5 18 11 16 false 270] [17 20 8 0 false 8] [17 20 28 0 false 12] [3 27 26 0 false 10] [33 30 8 0 false 0] [33 30 48 0 false 0] [65 40 49 0 false 0] [3 47 46 0 false 4] [129 50 49 0 false 0] [65 60 49 0 false 0] [3 67 66 0 false 10] [33 70 48 0 false 0] [33 70 88 0 false 0] [5 78 68 0 false 8] [5 78 58 0 false 6] [5 78 48 0 false 10] [5 78 38 0 false 6] [5 78 28 0 false 8] [5 78 88 0 false 4] [5 78 79 0 false 2] [5 78 77 0 false 0] [5 78 76 0 false 0] [5 78 75 0 false 0] [5 78 74 0 false 0] [5 78 71 16 false 270] [17 80 68 0 false 12] [17 80 88 0 false 8] [3 87 86 0 false 2] [9 90 89 0 false 10] [9 90 88 0 false 6]]

test3
[[3 7 6 0 false 2] [9 10 20 4 false 301] [9 10 9 0 false 10] [9 10 8 0 false 6][5 18 8 0 false 4] [5 18 28 0 false 8] [5 18 38 0 false 6] [5 18 48 0 false 10][5 18 58 0 false 6] [5 18 68 0 false 8] [5 18 78 0 false 0] [5 18 88 0 false 4][5 18 19 0 false 2] [5 18 17 0 false 0] [5 18 16 0 false 0] [5 18 15 0 false 0][5 18 14 0 false 0] [5 18 13 0 false 2] [5 18 12 0 false 2] [3 27 26 0 false 10][3 47 46 0 false 4] [129 50 49 0 false 0] [65 60 49 0 false 0] [3 67 66 0 false 10] [33 70 48 0 false 0] [33 70 88 0 false 0] [17 80 68 0 false 12] [17 80 88 0 false 8] [3 87 86 0 false 2] [9 90 89 0 false 10] [9 90 88 0 false 6]]
test4
and capturemoves
[[9 10 20 4 false 301]]
}

comment {
Testresults:
test  1  success
test  2  success
Test  Moves Generating ended.
Tests performed: 2
Successes: 2
Failed tests: 0

}