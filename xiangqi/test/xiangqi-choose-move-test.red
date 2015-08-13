Red [
	"Test iterative deepening search for the game of xiangqi aka Chinese Chess"
	filename: %xiangqi-choose-move-test.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "20-Mrt-2015"
	red-version: "Needs Red 0.5.0"
]

#include %../utils/xiangqi-helper-functions.red
#include %../xiangqi-common.red
#include %../xiangqi-move-common.red 
#include %../xiangqi-evaluate.red 
#include %../xiangqi-moves.red
#include %../xiangqi-best-move.red
#include %../xiangqi-open.red
;#include %../xiangqi-hash.red

comment { ; test of the functions
choose-move: function [
	"Choose moves from the openingbook, or other similar sources"
	found-moves [block!]
	return: [block!]

choose-move-from-list: function [
	"Choose moves from result of iterative deepening search"
	move-list [block!]
	depth [integer!]
	return: [block!]

}

cm-moves-1: [[ 1  2] 33 [ 3  4] 33 [ 5  6] 34]
cm-result: choose-move cm-moves-1
probe cm-result

cmfl-moves-1: []
cmfl-result: choose-move-from-list cmfl-moves-1
probe cmfl-result

cmfl-moves-2: [[8 12 14 0 false 99][16 12 14 0 false 99][32 12 14 0 false 99][8 12 14 0 false -99999]]
cmfl-result: choose-move-from-list cmfl-moves-2
probe cmfl-result

cmfl-moves-2: [[8 12 14 0 false 99 -99999][16 12 14 0 false 99 -99999][32 12 14 0 false -99999 -99999][8 12 14 0 false -99999 -99999]]
cmfl-result: choose-move-from-list cmfl-moves-2
probe cmfl-result

print "End of testprogram xiangqi-choose-move-test.red"