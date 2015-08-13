Red [
	"Found? replacement function while compiled Red 'Found? not supported"
	filename: %red-element-in-collection.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "20-Feb-2015"
	red-version: "Needs Red 0.5.0"
]
comment {
 Hopefully this file becomes obsolete one day, soon!
}

element-in-collection: function [
	input [integer! char! string!]
	collection [series!]
	return: [logic!]
	/local what [integer! block! string! char! logic!]
][
;	found? is unfortunately unsupported in Red
;	found? find collection input
	what: find collection input
	either none = what [false][true] 
]

comment {
element: 1
mycollection: [1 2 3]
if element-in-collection element mycollection [print ["I found" element " in collection" mycollection]]
}