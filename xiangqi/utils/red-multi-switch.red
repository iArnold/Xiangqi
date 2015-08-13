Red [
	"Switch replacement function while compiled Red 'switch cannot handle multiple case values"
	filename: %red-multi-switch.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "23-Feb-2015"
	red-version: "Needs Red 0.5.0"
]
comment {
 Hopefully this file becomes obsolete one day, soon!
 
 Warning: Do NOT nest calls to multi-switch, do not use with complicated block structures.
}

multi-switch: func [
    'var [word!]
    blk [block!]
    /default
    blk2 [block!]
    /local i [integer!] x [integer! char! string! block!]
][
    i: get var
    ;either found? find blk i [
	either element-in-collection i blk [
        x: select blk i
        either block! = type? x [
            do x
        ][   
            blk: find blk i
            until [
                blk: next blk
                x: first blk
                block! = type? x
            ]
            do x
        ]
    ][	; default
		if default [
			do blk2
        ]
    ]
]
