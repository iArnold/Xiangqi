Red [
	Title:		"Common Definitions"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2013-2016 Kaj de Vos. All rights reserved."
	License: {
		Redistribution and use in source and binary forms, with or without modification,
		are permitted provided that the following conditions are met:

		    * Redistributions of source code must retain the above copyright notice,
		      this list of conditions and the following disclaimer.
		    * Redistributions in binary form must reproduce the above copyright notice,
		      this list of conditions and the following disclaimer in the documentation
		      and/or other materials provided with the distribution.

		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
		ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
		WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
		DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
		FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
		DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
		SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
		CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
		OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
		OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	}
	Needs: {
		Red > 0.6
		%C-library/ANSI.reds
	}
	Tabs:		4
]


#system-global [#include %../C-library/ANSI.reds]


; Buffer working space

; WARN: not thread safe
binary*: make binary! 0
_string: make string! 0
_file: make file! 0
_block: make block! 0
_item: make block! 1


; Stack

stack: make block! 0

push: func ["Append value to stack."
	value
	/split			"Push values in a block individually."
][
	either split [
		append stack :value
	][
		append/only stack :value
	]
]
pop: function ["Return a value removed from top of stack."
	/local value
][
	value: last stack
	clear back tail stack
	value
]


; PARSE rules

blank:			charset " ^(tab)^(line)^M^(page)"

letter:			charset [#"A" - #"Z"  #"a" - #"z"]

digit:			charset "0123456789"
non-zero:		charset "123456789"
octal:			charset "01234567"
hexadecimal:	union digit charset [#"A" - #"F"  #"a" - #"f"]


; Binary

free-any: routine ["Release memory allocated through host operating system."
	binary			[integer!]  "binary!"
][
	free-any binary
]

free-binary: routine ["Release all memory of a binary array."
	binary			[integer!]  "array1!"
	/local			array
][
	unless zero? binary [
		array: as array1! binary
		free array/data
		free-any array
	]
]
size-of: routine ["Return size of a binary array."
	binary			[integer!]  "array1!"
	return:			[integer!]  "size!"
	/local			array
][
	either zero? binary [
		0
	][
		array: as array1! binary
		array/size
	]
]
data-of: routine ["Return data of a binary array."
	binary			[integer!]  "array1!"
	return:			[integer!]  "binary!"
	/local			array
][
	either zero? binary [
		0
	][
		array: as array1! binary
		as-integer array/data
	]
]

part-to-string: routine ["Return string converted from part of UTF-8 binary."
	data			[binary!]
	text			[string!]
	size			[integer!]
;	return:			[string!]
][
	string/rs-reset text  ; Ensure Latin 1

	if positive? size [
		unicode/load-utf8-buffer
			as-c-string binary/rs-head data  size
			GET_BUFFER (text)  null
			no
		text/cache: null
	]
	SET_RETURN (text)
]

percent-decode: function ["Return string with percent-escaped characters decoded."
	text			[string!]  "Text to decode (changed, returned)"
	return:			[string!]
	/local character high
][
	either find/case text #"%" [
		clear binary*
		parse text [any [
;			#"%" remove #"%"
;		|
			#"%" set high hexadecimal  set character hexadecimal
			(append binary*
				(either high > #"9" [
					5Fh and high - 55  ; - #"A" + 10
				][
					to integer! high - #"0"
				]) << 4 or  ; Red FIXME
				either character > #"9" [
					character and 5Fh - 55  ; - #"A" + 10
				][
					character - #"0"
				]
			)
		|
			set character skip (append binary* character)
		]]
		part-to-string binary* text  length? binary*
	][
		text
	]
]


; Program arguments

get-args-count: routine ["Return number of program arguments, excluding program name."
	return:			[integer!]
][
	system/words/get-args-count
]
take-argument: routine ["Consume and return next program argument."
;	return:			[string! none!]  "Argument, or NONE"
	/local			argument
][
	argument: system/words/take-argument

	either none? argument [
		RETURN_NONE
	][
		SET_RETURN ((string/load argument  length? argument  UTF-8))
;		end-argument argument
	]
]
get-argument: routine ["Return a program argument."
	offset			[integer!]  "0: program file name"
;	return:			[string! none!]  "Argument, or NONE"
	/local			argument
][
	argument: system/words/get-argument offset

	either none? argument [
		RETURN_NONE
	][
		SET_RETURN ((string/load argument  length? argument  UTF-8))
;		end-argument argument
	]
]
get-arguments: function ["Return program arguments, excluding program name."
	return:			[block! none!]
][
	all [
		0 < count: get-args-count
		(
			list: make block! count

			repeat i count [
				append list  get-argument i
			]
			list
		)
	]
]


comment {

; Bitwise operations

and~: routine ["Return bitwise AND operation of two integers."
	integer1		[integer!]
	integer2		[integer!]
	return:			[integer!]
][
	integer1 and integer2
]
or~: routine ["Return bitwise inclusive OR operation of two integers."
	integer1		[integer!]
	integer2		[integer!]
	return:			[integer!]
][
	integer1 or integer2
]
xor~: routine ["Return bitwise exclusive OR operation of two integers."
	integer1		[integer!]
	integer2		[integer!]
	return:			[integer!]
][
	integer1 xor integer2
]
and: make op! :and~
or:  make op! :or~
xor: make op! :xor~

shift-left: routine ["Return INTEGER with bits shifted left by BITS positions."
	integer			[integer!]
	bits			[integer!]
	return:			[integer!]
][
	integer << bits
]
shift-right: routine ["Return INTEGER with bits shifted right by BITS positions."
	integer			[integer!]
	bits			[integer!]
	return:			[integer!]
][
	integer >> bits
]
shift-logical: routine ["Return INTEGER with bits shifted right by BITS positions."
	integer			[integer!]
	bits			[integer!]
	return:			[integer!]
][
	integer >>> bits
]
<<:  make op! :shift-left
>>:  make op! :shift-right
>>>: make op! :shift-logical
shift: func ["Return INTEGER with bits shifted by BITS positions."
	integer			[integer!]
	bits			[integer!]
	/left			"Shift left"
	/logical		"Logical shift right (fill with zero)"
	/right			"Signed shift right"
	return:			[integer! none!]
][
	case [
		left	integer << bits
		logical	integer >>> bits
		right	integer >> bits
		yes		none
	]
]

}


; Unicode

#system [

	Latin1-to-UTF8: function ["Return UTF-8 encoding of Latin-1 text."
		series			[red-string!]
		return:			[c-string!]
		/local
			text tail char
			out index
	][
		text: string/rs-head series
		tail: string/rs-tail series

		out: allocate (as-integer tail - text) * 2 + 1
		if none? out [return null]
		index: out

		while [
			char: text/value  ; FIXME: tail overflow
			all [text < tail  char <> as-byte 0]
		][
			either char < as-byte 80h [
				index/1: char
				index: index + 1
			][
				index/2: char and (as-byte 3Fh) or as-byte 80h
				index/1: char >>> 6 or as-byte C0h
				index: index + 2
			]
			text: text + 1
		]
		index/1: null-byte
		as-c-string resize out  (as-integer index - out) + 1
	]

	UCS2-to-UTF8: function ["Return UTF-8 encoding of UCS-2 Unicode text."
		series			[red-string!]
		return:			[c-string!]
		/local
			text tail char
			pointer
			out index
	][
		text: string/rs-head series
		tail: string/rs-tail series

		out: allocate (as-integer tail - text) / 2 * 3 + 1 + 3  ; Safety padding
		if none? out [return null]
		index: out

		while [
			pointer: as pointer! [integer!] text
			char: pointer/value and FFFFh  ; FIXME: tail overflow
			all [text < tail  char <> 0]
		][
			case [  ; Basic Multilingual Plane
				char < 80h [
					index/1: as-byte char
					index: index + 1
				]
				char < 0800h [
					index/2: as-byte char and 3Fh or 80h
					index/1: as-byte char >>> 6 or C0h
					index: index + 2
				]
				yes [
					pointer: as pointer! [integer!] index
					pointer/value:
						char << 16 and 3F0000h
						or (char << 2 and 3F00h)
						or (char >>> 12)
						or 008080E0h
					index: index + 3
				]
			]
			text: text + 2
		]
		index/1: null-byte
		as-c-string resize out  (as-integer index - out) + 1
	]

	UCS4-to-UTF8: function ["Return UTF-8 encoding of UCS-4 Unicode text."
		series			[red-string!]
		return:			[c-string!]
		/local
			text tail char
			out index pointer
	][
		text: as pointer! [integer!] string/rs-head series
		tail: string/rs-tail series

		out: allocate (as-integer tail - text) + 1 + 3  ; Safety padding
		if none? out [return null]
		index: out

		while [
			char: text/value  ; FIXME: tail overflow
			all [text < tail  char <> 0]
		][
			case [
				char < 80h [
					index/1: as-byte char
					index: index + 1
				]
				char < 0800h [
					index/2: as-byte char and 3Fh or 80h
					index/1: as-byte char >>> 6 or C0h
					index: index + 2
				]
				char <= FFFFh [
					pointer: as pointer! [integer!] index
					pointer/value:
						char << 16 and 3F0000h
						or (char << 2 and 3F00h)
						or (char >>> 12)
						or 008080E0h
					index: index + 3
				]
				char < 00200000h [  ; Above BMP
					pointer: as pointer! [integer!] index
					pointer/value:
						char << 24 and 3F000000h
						or (char << 10 and 3F0000h)
						or (char >>> 4 and 3F00h)
						or (char >>> 18)
						or 808080F0h
					index: index + 4
				]
				yes [
					print-line "Error: UCS4-to-UTF8: codepoint above 1FFFFFh"
				]
			]
			text: text + 1
		]
		index/1: null-byte
		as-c-string resize out  (as-integer index - out) + 1
	]

	to-UTF8: function ["Return UTF-8 encoding of a Red string."
		text			[red-string!]
		return:			[c-string!]
		/local			series
	][
		series: GET_BUFFER (text)

		switch GET_UNIT (series) [
			Latin1	[Latin1-to-UTF8 text]
			UCS-2	[UCS2-to-UTF8 text]
			UCS-4	[UCS4-to-UTF8 text]
			default	[
				print-line ["Error: unknown text encoding: " GET_UNIT (series)]
				null
			]
		]
	]

	to-local-file: function ["Return file name encoded for local system."
		name			[red-string!]
		return:			[c-string!]
		/local series head size out
	][
		#switch OS [
			Windows [
				series: GET_BUFFER (name)

				unless Latin1 = GET_UNIT (series) [
					print-line ["Error: invalid file name encoding: " GET_UNIT (series)]
					return null
				]

				head: string/rs-head name
				size: (as-integer (string/rs-tail name) - head) + 1

;				if zero? size [return null]

				out: allocate size

				if as-logic out [
					copy-part head out  size - 1
					out/size: null-byte
				]
				as-c-string out
			]
			#default [
				to-UTF8 name
			]
		]
	]

]

file-to-local-file: routine [
	name			[file!]
	return:			[integer!]  "c-string!"
][
	as-integer to-local-file as red-string! name
]
url-to-local-file: routine [
	name			[url!]
	return:			[integer!]  "c-string!"
][
	as-integer to-local-file as red-string! name
]
to-local-file: func ["Return file name encoded for local system."
	name			[file! url!]
	return:			[integer! none!]  "c-string!; NONE: error"
][
;	unless zero? name: either file? name [
	either zero? name: either file? name [
		file-to-local-file name
	][
		url-to-local-file name
	][
		print "Error: to-local-file"
	][
		name
	]
]

length-of: routine ["Return size of a C string, excluding null tail marker."
	text			[integer!]  "c-string!"
	return:			[integer!]
][
	length? as-c-string text  ; size? - 1
]
UTF8-size-of: routine ["Return UTF-8 size of a Red string, excluding null tail marker."
	text			[string!]
;	return:			[integer! none!]  "NONE: error"
	/local			UTF-8
][
	UTF-8: to-UTF8 text

	either none? UTF-8 [
		RETURN_NONE
	][
		integer/box length? UTF-8  ; size? - 1
		free-any UTF-8
	]
]
size-of-string: func ["Return C size of a string, excluding null tail marker."
	text			[string! integer!]
	return:			[integer! none!]  "NONE: error"
][
	either integer? text [
		length-of text
	][
		either empty? text [0] [UTF8-size-of text]
	]
]

to-binary: routine ["Return string converted to UTF-8 binary."
	text			[string!]
;	return:			[integer! none!]  "NONE: error"
	/local array UTF-8
][
	array: as array1! allocate size? array1!

	either none? array [
		RETURN_NONE
	][
		UTF-8: to-UTF8 text

		either none? UTF-8 [
			free-any array
			RETURN_NONE
		][
			array/data: as-binary UTF-8
			array/size: length? UTF-8  ; Excluding null tail marker
			integer/box as-integer array
		]
	]
]

join-UTF8-binary: routine ["Return string converted to UTF-8 binary, joined with other binary."
	text			[string!]
	binary			[integer!]  "array1!"
;	return:			[integer! none!]  "NONE: error"
	/local in out UTF-8 length data
][
	out: as array1! allocate size? array1!

	either none? out [
		RETURN_NONE
	][
		UTF-8: to-UTF8 text

		either none? UTF-8 [
			free-any out
			RETURN_NONE
		][
			length: length? UTF-8  ; Excluding null tail marker
			in: as array1! binary
			out/size: length + in/size
			data: resize as-binary UTF-8  out/size

			either none? data [
				free-any UTF-8
				free-any out
				RETURN_NONE
			][
				copy-part in/data  data + length  in/size
				out/data: data
				integer/box as-integer out
			]
		]
	]
]
join: function ["Copy SERIES and append VALUE."
	series			[series!]
	value
	return:			[series! integer! none!]
][
	either all [string? series  integer? value] [
		join-UTF8-binary series value
	][
		append copy series  value
	]
]


; Common functions

Windows?: system/platform = 'Windows

found?: func ["Test if value is not NONE."
	value
	return:			[logic!]
][
	not none? :value
]

comment {

any-word!: [word! lit-word! set-word! get-word! issue! refinement! datatype!]
any-string!: [string! file!]
any-block!: [block! paren! path! lit-path! set-path! get-path!]

any-word?: func ["Test if value is a word of any type."
	value
	return:			[logic!]
][
	found? find any-word! type?/word :value
]
series?: func ["Test if value is a series of any type."
	value
	return:			[logic!]
][
	found? any-series? :value
]
any-string?: func ["Test if value is a string of any type."
	value
	return:			[logic!]
][
	found? find any-string! type?/word :value
]
any-block?: func ["Test if value is a block of any type."
	value
	return:			[logic!]
][
	found? find any-block! type?/word :value
]

}

last?: func ["Test if series has just one element."
	series			[series!]
	return:			[logic!]
][
	1 = length? series
]
single?: func ["Test if series has just one element."
	series			[series!]
	return:			[logic!]
][
	last? series
]

comment {
offset?: func ["Return difference between two positions in a series."
	series1			[series!]
	series2			[series!]
	return:			[integer!]
][
	subtract index? series2  index? series1
]
}

before-last: func ["Return next to last value of series."
	series			[series!]
][
	pick tail series -2
]

split*: function ["Return SERIES in pieces split at DELIMITER."
	series			[series!]
	delimiter
	/case			"Find delimiters strictly."
	/only			"Split single elements as series instead of elements."
	return:			[block!]
][
	out: make block! 0

	unless empty? series [
		length: either series? delimiter [length? delimiter] [1]

		while [here: either case
			[find/case series delimiter] [find series delimiter]
		][
			append/only out  either any [only  1 < offset? series here]
				[copy/part series here] [series/1]
			series: skip here length
		]
		append/only out  either all [last? series  not only]
			[series/1] [copy series]
	]
	out
]

clean-path*: function [
	"Remove unneeded constructs from a path and check that it doesn't point outside its base folder."
	file			[file! url! string!]	"File path to clean (changed, returned)"
	return:			[file! string! none!]	"NONE: path is unsafe"
][
	this: [any [opt #"."  #"/"]]
	parent: [2 #"." [#"/" this | end]]

	all [
		parse/case file [
			[	if (not url? file)
			|
				thru #":"  any #"/" [thru #"/" | thru #":" | to end]
			]
			opt remove [#"."  ahead [some #"/"  skip]]  ; TODO: replace with current directory
			while [
				while [
					#"/" remove this
					| ahead parent  reject  ; Red FIXME: REJECT should not need AHEAD
					| remove [thru #"/"  this parent]  ; TODO: REVERSE
					| to #"/"
					| to end  break
				]
				break
			|
				ahead [opt #"/"  parent] reject
			]
		]
		file
	]
]

count: function ["Return number of occurrences of VALUE in SERIES."
	series			[series!]
	value
	/case			"Find VALUE strictly."
	return:			[integer!]
][
	count*: 0  ; Red FIXME

	while [series: either case
		[find/tail/case series :value] [find/tail series :value]
	][
		count*: count* + 1
	]
	count*
]
count-lines: func ["Return number of lines in STRING."
	string			[string!]
	return:			[integer!]
][
	1 + do [count string newline]  ; Red FIXME
]

break-line: function ["Set line break on a single value."
	value
][
	first new-line append/only clear _item  value yes
]
break-lines: function ["Set multiple line breaks from PLACE at SIZE intervals."
	place			[any-block!]
	size			[integer!]
	return:			[any-block!]
][
	if size < length? place [new-line/all/skip place yes size]

	place
]
