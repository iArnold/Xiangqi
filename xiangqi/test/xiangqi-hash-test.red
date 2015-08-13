Red [
	"Test hash computing for the game of xiangqi aka Chinese Chess"
	filename: %xiangqi-hash-test.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "7-Feb-2015"
]

#include %../xiangqi-hash.red

; tests 
key-part: 2514
print integer-to-base64 key-part

key-part: 2586
print integer-to-base64 key-part

key-part: 2514 << 18 + 2586
print integer-to-base64 key-part

; Expected results test 1 + 2 + 3
; nS
; oa
; nSAoa

; test 4
key: [804 2514 804 954 2586 954]
convert-to-base64 key
; == "AnSAoaAMkAO6AMkAO6"

; test 5
key: [884 2514 804 954 2586 954]
convert-to-base64 key
; == "AnSAoaAN0AO6AMkAO6"

; test 6 + 7
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

calculate-hash-code play-board
my-hash: calculate-new-hash-from-move play-board [804 2514 804 954 2586 954] 1 2
probe my-hash
; Expected result
; [884 2514 804 954 2586 954]

print calculate-new-hash-code-from-move play-board [804 2514 804 954 2586 954] 1 2
; Expected result
; AnSAoaAN0AO6AMkAO6

