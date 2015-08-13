Red [
	"Power replacement function while compiled Red 'power is not around"
	filename: %red-power.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "25-Feb-2015"
	red-version: "Needs Red 0.5.0"
]

xiangqi-power: function [
	base-number [number!]
	exponent [number!]
	return: [number!]
][
	either 0 = exponent [
		return 1
	][	; only 1 or -1 as answers needed for this use in the Xiangqi program
		; so not making it more difficult than necessary
		return -1
	]

]