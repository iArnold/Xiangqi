Red [
	Title:		"Local file Input/Output"
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
		Red >= 0.6
		%common/common.red
	}
	Tabs:		4
]


#include %../common/common.red


context [  ; Red FIXME

	read-string: routine ["Read and return a UTF-8 text file."
		name			[integer!]  "c-string!"  ; [file! url!]
;		return:			[string! none!]
		/local file text length
	][
		length: 0
		file: as-c-string name

		if zero? compare-string-part file "file:" 5 [file: file + 5]

		text: read-file file :length

		either none? text [
			RETURN_NONE
		][
			SET_RETURN ((string/load text length UTF-8))
			free-any text
		]
	]
	read-string-binary: routine ["Read a text file, return it as binary."
		name			[integer!]  "c-string!"  ; [file! url!]
;		return:			[integer! none!]
		/local file array text length
	][
		length: 0
		file: as-c-string name

		if zero? compare-string-part file "file:" 5 [file: file + 5]

		text: read-file file :length

		either none? text [
			RETURN_NONE
		][
			array: as array1! allocate size? array1!

			either none? array [
				free-any text
				RETURN_NONE
			][
				array/data: as-binary text
				array/size: length  ; Excluding null tail marker
				integer/box as-integer array
			]
		]
	]
	read-binary: routine ["Read and return a binary file."
		name			[integer!]  "c-string!"  ; [file! url!]
;		return:			[integer! none!]
		/local file array data size
	][
		size: 0
		file: as-c-string name

		if zero? compare-string-part file "file:" 5 [file: file + 5]

		data: read-file-binary file :size

		either none? data [
			RETURN_NONE
		][
			array: as array1! allocate size? array1!

			either none? array [
				free data
				RETURN_NONE
			][
				array/data: data
				array/size: size
				integer/box as-integer array
			]
		]
	]
	set 'read* function [								"Read and return a file."
		name			[file! url! string! integer!]
		/binary											"Return file as binary."
		/string											"Read file as text."
		/lines											"Return block of text lines."
		return:			[string! block! integer! none!]
	][
		if name*: either integer? name [name] [to-local-file name] [
			ok: either binary [
				either string [read-string-binary name*] [read-binary name*]
			][
				if file: read-string name* [
					either lines [split*/only file newline] [file]
				]
			]
			unless integer? name [free-any name*]

			ok
		]
	]

	write-string: routine ["Write UTF-8 text file."
		name			[integer!]  "c-string!"  ; [file! url!]
		text			[string!]
		return:			[logic!]
		/local file out ok?
	][
		file: as-c-string name

		if zero? compare-string-part file "file:" 5 [file: file + 5]

		out: to-UTF8 text
		ok?: write-file file out
		free-any out
		ok?
	]
	write-binary-part: routine ["Write binary file."
		name			[integer!]  "c-string!"  ; [file! url!]
		data			[integer!]  "binary!"
		size			[integer!]
		return:			[logic!]
		/local			file
	][
		file: as-c-string name

		if zero? compare-string-part file "file:" 5 [file: file + 5]

		write-file-binary file  as-binary data  size
	]
	write-binary: routine ["Write binary file."
		name			[integer!]  "c-string!"  ; [file! url!]
		data			[integer!]  "array1!"
		return:			[logic!]
		/local			array
	][
		either zero? data [
			no
		][
			array: as array1! data
			write-binary-part name  as-integer array/data  array/size
		]
	]
	set 'write* function [								"Write file."
		name			[file! url! string! integer!]
		data			[string! integer!]
		/part											"Write (part of) binary DATA."
			size		[integer!]
		return:			[logic! none!]
	][
		all [
			name*: either integer? name [name] [to-local-file name]
			(
				ok?: either string? data [
					write-string name* data
				][
					either part [
						write-binary-part name* data size
					][
						write-binary name* data
					]
				]
				unless integer? name [free-any name*]

				ok?
			)
		]
	]


comment {

	load**: :load

	load: function ["Return a value or block of values by loading a source."
		source			[string! file! url!]
		/all							"Always return a block."
		/into							"Insert result into existing block."
			out			[block!]		"Result buffer"
	][
		if any [file? source  url? source] [source: read source]

		all [
			source
			either all [
				either into [
					do [load**/all/into source out]
				][
					do [load**/all source]
				]
			][
				either into [
					do [load**/into source out]
				][
					do [load** source]
				]
			]
		]
	]

	do*: :do
	result: make block! 1  ; WARN: not thread safe

	set 'do function ["Execute code from a source."
		source
	][
		if any [file? source  url? source] [source: read source]

		first head reduce/into dummy: [do* source] clear result  ; Force use of interpreter
	]

}

]
