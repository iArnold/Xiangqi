Red [
	"Found? replacement function while compiled Red 'Found? not supported"
	filename: %red-found.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "3-Apr-2015"
	red-version: "Needs Red 0.5.1"
]

found?: function [
	input [none! string! block! series!]
	return: [logic!]
][
	either none? input [
		return false
	][
		return true
	]
]

comment {
print form found? find [1 2 3 4] 2
print form found? find "1-2-3-4" "/"
print form found? find "1/2/3/4" "/"
print form found? find ["Hello" [1 2 3 4] "Goodday" [true]] "Goodday"
}