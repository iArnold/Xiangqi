Red [
	Title:		"ANSI C Library Binding"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2016 Kaj de Vos. All rights reserved."
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
		%ANSI.reds
		%common/common.red
	}
	Tabs:		4
]


;#system-global [#include %ANSI.reds]
#include %../common/common.red


; Parsing

load-integer: routine ["Return integer parsed from string."
	string			[string!]
;	return:			[integer! none!]
	/local			text
][
	text: to-UTF8 string

	either none? text [
		RETURN_NONE
	][
		integer/box to-integer text
		free-any text
	]
]
load-hex: routine ["Return integer parsed from hexadecimal string."
	string			[string!]
;	return:			[integer! none!]
	/local text result ok?
][
	text: to-UTF8 string

	either none? text [  ; Needed?
		RETURN_NONE
	][
		result: 0
		ok?: parse-hex text :result
		free-any text

		either ok? [
			integer/box result
		][
			RETURN_NONE
		]
	]
]
load-octal: routine ["Return integer parsed from octal string."
	string			[string!]
;	return:			[integer! none!]
	/local text result ok?
][
	text: to-UTF8 string

	either none? text [  ; Needed?
		RETURN_NONE
	][
		result: 0
		ok?: parse-octal text :result
		free-any text

		either ok? [
			integer/box result
		][
			RETURN_NONE
		]
	]
]


; Conversion

char-to-integer: routine ["Return integer (Unicode codepoint) value of character."
	character		[char!]
	return:			[integer!]
][
	character/value
]
to-integer: func ["Return integer converted from other types."
	value			[char! string!]
	return:			[integer! none!]
][
	either char? value [
		char-to-integer value
	][
		load-integer value
	]
]


comment {

; Formatting

to-hex-size: routine ["Return integer formatted as hexadecimal string."
	number			[integer!]
	length			[integer!]  "Number of digits"
;	return:			[string! none!]
	/local			text
][
	text: form-hex number length

	either none? text [
		RETURN_NONE
	][
		SET_RETURN ((string/load text  length? text  UTF-8))
;		free-any text
	]
]
to-hex: func ["Return integer formatted as hexadecimal string."
	number			[integer! char!]
	/size
		length		[integer!]  "Number of digits"
	return:			[string! none!]
][
	to-hex-size number  any [length 8]
]

}


; Input/output

input*: routine ["Return a line read from standard input."
;	return:			[string! none!]
	/local			line
][
	line: input

	either none? line [
		RETURN_NONE  ; FIXME: report error
	][
		SET_RETURN ((string/load line  length? line  UTF-8))
;		free-any line
	]
]
ask*: function ["Prompt for input, then return a line read from standard input."
	question		[string!]
	return:			[string! none!]
][
	prin question
	input*
]


; Dates and time

date-with: routine ["Return date or time component."
	time			[integer!]  "time!"
	utc?			[logic!]
	zone?			[logic!]
	date?			[logic!]
	time?			[logic!]
	year?			[logic!]
	month?			[logic!]
	day?			[logic!]
	hour?			[logic!]
	minute?			[logic!]
	second?			[logic!]
	weekday?		[logic!]
	yearday?		[logic!]
;	return:			[string! integer! none!]
	/local			date minutes zone sign day text
][
	date: to-date :time

	either none? date [
		RETURN_NONE
	][
		minutes: date/hour * 60 + date/minute

		date: to-local-date :time
		zone: date/hour * 60 + date/minute - minutes

		if utc? [date: to-date :time]

		case [
			second?		[integer/box date/second]
			minute?		[integer/box date/minute]
			hour?		[integer/box date/hour]
			day?		[integer/box date/day]
			month?		[integer/box date/month + 1]
			year?		[integer/box date/year + 1900]
			yearday?	[integer/box date/yearday + 1]
			weekday? [
				day: date/weekday

				; REBOL has a wrong world view
				integer/box either as-logic day [day] [7]  ; Sunday
			]
			yes [
				text: make-c-string 27

				either none? text [
					RETURN_NONE  ; FIXME: report error
				][
					either zone > 720 [  ; 12 hours
						zone: zone - 1440  ; 24 hours
					][
						if zone <= -720 [zone: zone + 1440]
					]
					sign: either negative? zone [
						zone: negate zone
						#"-"
					][
						#"+"
					]
					case [
						zone? [
							either 5 <= format-any [text "%c%i:%02i" sign  zone / 60  zone // 60] [
								SET_RETURN ((string/load text  length? text  UTF-8))
							][	; FIXME: report error
								RETURN_NONE
							]
						]
						date? [
							either format-date text 27 "%d-%b-%Y" date [
								SET_RETURN ((string/load text  length? text  UTF-8))
							][	; FIXME: report error
								RETURN_NONE
							]
						]
						time? [
							either format-date text 27 "%H:%M:%S" date [
								SET_RETURN ((string/load text  length? text  UTF-8))
							][	; FIXME: report error
								RETURN_NONE
							]
						]
						yes [
							either format-date text 27 "%d-%b-%Y/%H:%M:%S" date [
								either any [utc?  25 <= format-any [text "%s%c%i:%02i" text sign  zone / 60  zone // 60]] [
									SET_RETURN ((string/load text  length? text  UTF-8))
								][	; FIXME: report error
									RETURN_NONE
								]
							][	; FIXME: report error
								RETURN_NONE
							]
						]
					]
					free-any text
				]
			]
		]
	]
]
date: function ["Return date or time component."
	value			[integer!]  "time!"
	/precise
	/utc /zone
	/date /time
	/year /month /day
	/hour /minute /second
	/weekday /yearday
	return:			[string! integer! none!]
][
	unless value = -1 [
		either precise [
			value
		][
			date-with
				value
				utc zone
				date time
				year month day
				hour minute second
				weekday yearday
		]
	]
]
now-time: routine ["Return current time."
	return:			[integer!]  "time!"
][
	system/words/now-time null
]
now*: function ["Return current time."
	/precise
	/utc /zone
	/date /time
	/year /month /day
	/hour /minute /second
	/weekday /yearday
	return:			[string! integer! none!]
][
	unless -1 = value: now-time [
		either precise [
			value
		][
			date-with
				value
				utc zone
				date time
				year month day
				hour minute second
				weekday yearday
		]
	]
]

subtract-time: routine ["Return time difference in seconds: time-1 - time-2"
	time-1			[integer!]  "time!"
	time-2			[integer!]  "time!"
;	return:			[float!]  "Seconds"  ; Red FIXME
][
	float/box system/words/subtract-time time-1 time-2
]

clocks-per-second: routine ["Return clock ticks per second"
	return:			[integer!]
][
	clocks-per-second
]
get-process-time: routine ["Return CPU time used by process; wall-clock time on Windows!"
	return:			[integer!]  "-1: unknown"
][
	system/words/get-process-time
]
get-process-seconds: function ["Return CPU time used by process in seconds; wall-clock time on Windows!"
	return:			[float! none!]  "Seconds"
	/local			time
][
	unless -1 = time: get-process-time [
		time / to float! clocks-per-second  ; TODO: optimise
	]
]


comment {

; Random numbers

random-with: routine ["Return pseudo-random number from 1 thru NUMBER."
	number			[integer!]
	seed?			[logic!]  "Restart the sequence with new seed NUMBER (initially 1)?"
	secure?			[logic!]  "Use time-based seed?"
;	return:			[integer! unset!]
][
	either seed? [
		either secure? [random-seed-secure] [random-seed number]
		RETURN_UNSET
	][
		integer/box random number
	]
]
random: function ["Return pseudo-random number from 1 thru NUMBER."
	number			[integer!]
	/seed			"Restart the sequence with new seed NUMBER (initially 1)."
	/secure			"Use time-based seed."
	return:			[integer! unset!]
][
	random-with number seed secure
]

}


; System interfacing

get-environment: routine ["Return system environment variable."
	name			[string!]
;	return:			[string! none!]
	/local text value
][
	text: to-UTF8 name
	value: system/words/get-environment text
	free-any text

	either none? value [
		RETURN_NONE
	][
		SET_RETURN ((string/load value  length? value  UTF-8))
;		free-any value  ; ?
	]
]

call-system*: routine ["Execute external system command."
	command			[string!]
	return:			[integer!]
	/local text status
][
	text: to-UTF8 command
	status: call text
	free-any text
	status
]
call-system: function ["Execute external system command."
	command			[string!]
	/wait			"Await command's return."
	return:			[integer!]
][
	; TODO: no-wait on Windows
	call-system* either any [wait Windows?] [command] [append copy command  " &"]
]
