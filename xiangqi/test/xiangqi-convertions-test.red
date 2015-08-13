Red [
	"Test convertion for the game of xiangqi aka Chinese Chess"
	filename: %xiangqi-convertion-test.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "21-Feb-2015"
	red-version: "Needs Red 0.5.0"
]

#include %../xiangqi-common.red
#include %../xiangqi-convertions.red

init-convertions-test: func [] [
	testname: "Convertions"
	convertions-test-results: 0
	convertions-tests: 0
]

convertions-result: func [
	testresult [logic! integer! block!]
][
	convertions-tests: convertions-tests + 1

	either expected-result = testresult [
		print ["test " convertions-tests " success" expected-result "equals" testresult]
		convertions-test-results: convertions-test-results + 1
	][
		print ["test " convertions-tests " failed"  expected-result "not equals" testresult]
	]
]

conclude-test: function [
][
	print ["Test " testname "ended."]
	print ["Tests performed:" convertions-tests]
	print ["Successes:" convertions-test-results]
	print ["Failed tests:" convertions-tests - convertions-test-results ]
	
]

; Calling the function to be tested
comment {
field-to-xy: function [
	field [integer!]
	return: [block!]
xy-to-field: function [
	x [integer!]
	y [integer!]
}

init-convertions-test

;*********************
; Tests of field-to-xy
;*********************
comment {
all-fields-as-xy: [
[1 1] [1 2] [1 3] [1 4] [1 5] [1 6] [1 7] [1 8] [1 9] [1 10]
[2 1] [2 2] [2 3] [2 4] [2 5] [2 6] [2 7] [2 8] [2 9] [2 10]
[3 1] [3 2] [3 3] [3 4] [3 5] [3 6] [3 7] [3 8] [3 9] [3 10]
[4 1] [4 2] [4 3] [4 4] [4 5] [4 6] [4 7] [4 8] [4 9] [4 10]
[5 1] [5 2] [5 3] [5 4] [5 5] [5 6] [5 7] [5 8] [5 9] [5 10]
[6 1] [6 2] [6 3] [6 4] [6 5] [6 6] [6 7] [6 8] [6 9] [6 10]
[7 1] [7 2] [7 3] [7 4] [7 5] [7 6] [7 7] [7 8] [7 9] [7 10]
[8 1] [8 2] [8 3] [8 4] [8 5] [8 6] [8 7] [8 8] [8 9] [8 10]
[9 1] [9 2] [9 3] [9 4] [9 5] [9 6] [9 7] [9 8] [9 9] [9 10]
]
}

; Make sure these have the right value for this test
start-position-h: start-position-v: 80 ; 80 pixels?
field-size: 100 	                 ; 100 pixels?

all-fields-as-xy: [
[80 980]  [80 880]  [80 780]  [80 680]  [80 580]  [80 480]  [80 380]  [80 280]  [80 180]  [80 80]  
[180 980] [180 880] [180 780] [180 680] [180 580] [180 480] [180 380] [180 280] [180 180] [180 80] 
[280 980] [280 880] [280 780] [280 680] [280 580] [280 480] [280 380] [280 280] [280 180] [280 80] 
[380 980] [380 880] [380 780] [380 680] [380 580] [380 480] [380 380] [380 280] [380 180] [380 80] 
[480 980] [480 880] [480 780] [480 680] [480 580] [480 480] [480 380] [480 280] [480 180] [480 80] 
[580 980] [580 880] [580 780] [580 680] [580 580] [580 480] [580 380] [580 280] [580 180] [580 80] 
[680 980] [680 880] [680 780] [680 680] [680 580] [680 480] [680 380] [680 280] [680 180] [680 80] 
[780 980] [780 880] [780 780] [780 680] [780 580] [780 480] [780 380] [780 280] [780 180] [780 80] 
[880 980] [880 880] [880 780] [880 680] [880 580] [880 480] [880 380] [880 280] [880 180] [880 80] 
]

repeat field 90 [
	expected-result: all-fields-as-xy/:field
	convertions-result field-to-xy field
]

;*********************
; Tests of xy-to-field
;*********************
repeat field 90 [
	expected-result: field
	convertions-result xy-to-field all-fields-as-xy/:field/1 all-fields-as-xy/:field/2
]

;****************************
; Tests of display-moves-list
;****************************
move-list: [[1 2] [1 3] [2 3] [2 4] [2 5]]
expected-result: [ 1 [2 3] 2 [3 4 5] ]
convertions-result display-moves-list move-list

;**************************
; Print and display a board
;**************************
print-board start-board

init-xiangqi-display-set/snmg

display-board start-board
display-board/numbers start-board

init-xiangqi-display-set/standard

display-board start-board
display-board/numbers start-board


;********************************
; Add more tests here (181+)
;********************************



conclude-test

comment {
test  1  success 80 980 equals 80 980
test  2  success 80 880 equals 80 880
test  3  success 80 780 equals 80 780
test  4  success 80 680 equals 80 680
test  5  success 80 580 equals 80 580
test  6  success 80 480 equals 80 480
test  7  success 80 380 equals 80 380
test  8  success 80 280 equals 80 280
test  9  success 80 180 equals 80 180
test  10  success 80 80 equals 80 80
test  11  success 180 980 equals 180 980
test  12  success 180 880 equals 180 880
test  13  success 180 780 equals 180 780
test  14  success 180 680 equals 180 680
test  15  success 180 580 equals 180 580
test  16  success 180 480 equals 180 480
test  17  success 180 380 equals 180 380
test  18  success 180 280 equals 180 280
test  19  success 180 180 equals 180 180
test  20  success 180 80 equals 180 80
test  21  success 280 980 equals 280 980
test  22  success 280 880 equals 280 880
test  23  success 280 780 equals 280 780
test  24  success 280 680 equals 280 680
test  25  success 280 580 equals 280 580
test  26  success 280 480 equals 280 480
test  27  success 280 380 equals 280 380
test  28  success 280 280 equals 280 280
test  29  success 280 180 equals 280 180
test  30  success 280 80 equals 280 80
test  31  success 380 980 equals 380 980
test  32  success 380 880 equals 380 880
test  33  success 380 780 equals 380 780
test  34  success 380 680 equals 380 680
test  35  success 380 580 equals 380 580
test  36  success 380 480 equals 380 480
test  37  success 380 380 equals 380 380
test  38  success 380 280 equals 380 280
test  39  success 380 180 equals 380 180
test  40  success 380 80 equals 380 80
test  41  success 480 980 equals 480 980
test  42  success 480 880 equals 480 880
test  43  success 480 780 equals 480 780
test  44  success 480 680 equals 480 680
test  45  success 480 580 equals 480 580
test  46  success 480 480 equals 480 480
test  47  success 480 380 equals 480 380
test  48  success 480 280 equals 480 280
test  49  success 480 180 equals 480 180
test  50  success 480 80 equals 480 80
test  51  success 580 980 equals 580 980
test  52  success 580 880 equals 580 880
test  53  success 580 780 equals 580 780
test  54  success 580 680 equals 580 680
test  55  success 580 580 equals 580 580
test  56  success 580 480 equals 580 480
test  57  success 580 380 equals 580 380
test  58  success 580 280 equals 580 280
test  59  success 580 180 equals 580 180
test  60  success 580 80 equals 580 80
test  61  success 680 980 equals 680 980
test  62  success 680 880 equals 680 880
test  63  success 680 780 equals 680 780
test  64  success 680 680 equals 680 680
test  65  success 680 580 equals 680 580
test  66  success 680 480 equals 680 480
test  67  success 680 380 equals 680 380
test  68  success 680 280 equals 680 280
test  69  success 680 180 equals 680 180
test  70  success 680 80 equals 680 80
test  71  success 780 980 equals 780 980
test  72  success 780 880 equals 780 880
test  73  success 780 780 equals 780 780
test  74  success 780 680 equals 780 680
test  75  success 780 580 equals 780 580
test  76  success 780 480 equals 780 480
test  77  success 780 380 equals 780 380
test  78  success 780 280 equals 780 280
test  79  success 780 180 equals 780 180
test  80  success 780 80 equals 780 80
test  81  success 880 980 equals 880 980
test  82  success 880 880 equals 880 880
test  83  success 880 780 equals 880 780
test  84  success 880 680 equals 880 680
test  85  success 880 580 equals 880 580
test  86  success 880 480 equals 880 480
test  87  success 880 380 equals 880 380
test  88  success 880 280 equals 880 280
test  89  success 880 180 equals 880 180
test  90  success 880 80 equals 880 80
test  91  success 1 equals 1
test  92  success 2 equals 2
test  93  success 3 equals 3
test  94  success 4 equals 4
test  95  success 5 equals 5
test  96  success 6 equals 6
test  97  success 7 equals 7
test  98  success 8 equals 8
test  99  success 9 equals 9
test  100  success 10 equals 10
test  101  success 11 equals 11
test  102  success 12 equals 12
test  103  success 13 equals 13
test  104  success 14 equals 14
test  105  success 15 equals 15
test  106  success 16 equals 16
test  107  success 17 equals 17
test  108  success 18 equals 18
test  109  success 19 equals 19
test  110  success 20 equals 20
test  111  success 21 equals 21
test  112  success 22 equals 22
test  113  success 23 equals 23
test  114  success 24 equals 24
test  115  success 25 equals 25
test  116  success 26 equals 26
test  117  success 27 equals 27
test  118  success 28 equals 28
test  119  success 29 equals 29
test  120  success 30 equals 30
test  121  success 31 equals 31
test  122  success 32 equals 32
test  123  success 33 equals 33
test  124  success 34 equals 34
test  125  success 35 equals 35
test  126  success 36 equals 36
test  127  success 37 equals 37
test  128  success 38 equals 38
test  129  success 39 equals 39
test  130  success 40 equals 40
test  131  success 41 equals 41
test  132  success 42 equals 42
test  133  success 43 equals 43
test  134  success 44 equals 44
test  135  success 45 equals 45
test  136  success 46 equals 46
test  137  success 47 equals 47
test  138  success 48 equals 48
test  139  success 49 equals 49
test  140  success 50 equals 50
test  141  success 51 equals 51
test  142  success 52 equals 52
test  143  success 53 equals 53
test  144  success 54 equals 54
test  145  success 55 equals 55
test  146  success 56 equals 56
test  147  success 57 equals 57
test  148  success 58 equals 58
test  149  success 59 equals 59
test  150  success 60 equals 60
test  151  success 61 equals 61
test  152  success 62 equals 62
test  153  success 63 equals 63
test  154  success 64 equals 64
test  155  success 65 equals 65
test  156  success 66 equals 66
test  157  success 67 equals 67
test  158  success 68 equals 68
test  159  success 69 equals 69
test  160  success 70 equals 70
test  161  success 71 equals 71
test  162  success 72 equals 72
test  163  success 73 equals 73
test  164  success 74 equals 74
test  165  success 75 equals 75
test  166  success 76 equals 76
test  167  success 77 equals 77
test  168  success 78 equals 78
test  169  success 79 equals 79
test  170  success 80 equals 80
test  171  success 81 equals 81
test  172  success 82 equals 82
test  173  success 83 equals 83
test  174  success 84 equals 84
test  175  success 85 equals 85
test  176  success 86 equals 86
test  177  success 87 equals 87
test  178  success 88 equals 88
test  179  success 89 equals 89
test  180  success 90 equals 90
test  180  success 90 equals 90
test  181  success 1 2 3 2 3 4 5 equals 1 2 3 2 3 4 5
   9  17  33  65 129  65  33  17   9

   0   0   0   0   0   0   0   0   0

   0   5   0   0   0   0   0   5   0

   3   0   3   0   3   0   3   0   3

   0   0   0   0   0   0   0   0   0

   0   0   0   0   0   0   0   0   0

   2   0   2   0   2   0   2   0   2

   0   4   0   0   0   0   0   4   0

   0   0   0   0   0   0   0   0   0

   8  16  32  64 128  64  32  16   8

   1  2  3  4  5  6  7  8  9
  ----------------------------
   r  h  e  a  k  a  e  h  r
   .  .  .  .  .  .  .  .  .
   .  c  .  .  .  .  .  c  .
   p  .  p  .  p  .  p  .  p
   .  .  .  .  .  .  .  .  .
   .  .  .  .  .  .  .  .  .
   P  .  P  .  P  .  P  .  P
   .  C  .  .  .  .  .  C  .
   .  .  .  .  .  .  .  .  .
   R  H  E  A  K  A  E  H  R
  ----------------------------
   9  8  7  6  5  4  3  2  1
   1  2  3  4  5  6  7  8  9
  ----------------------------
   r  h  e  a  k  a  e  h  r
  10 20 30 40 50 60 70 80 90
   .  .  .  .  .  .  .  .  .
   9 19 29 39 49 59 69 79 89
   .  c  .  .  .  .  .  c  .
   8 18 28 38 48 58 68 78 88
   p  .  p  .  p  .  p  .  p
   7 17 27 37 47 57 67 77 87
   .  .  .  .  .  .  .  .  .
   6 16 26 36 46 56 66 76 86
   .  .  .  .  .  .  .  .  .
   5 15 25 35 45 55 65 75 85
   P  .  P  .  P  .  P  .  P
   4 14 24 34 44 54 64 74 84
   .  C  .  .  .  .  .  C  .
   3 13 23 33 43 53 63 73 83
   .  .  .  .  .  .  .  .  .
   2 12 22 32 42 52 62 72 82
   R  H  E  A  K  A  E  H  R
   1 11 21 31 41 51 61 71 81
  ----------------------------
   9  8  7  6  5  4  3  2  1
Test  Convertions ended.
Tests performed: 181
Successes: 181
Failed tests: 0

}