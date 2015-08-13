Red [
	"Calculate the best move in a given position for the game of xiangqi aka Chinese Chess"
	filename: %xiangqi-best-move.red
	author:   "Arnold van Hofwegen"
	version:  0.2
	date:     "06-Aug-2015"
	needs:    "%xiangqi-common.red #include via main program or testprogram"
]
;***********************************************************
; Routines to determine which move from the list is the best
;***********************************************************

;***************
; Move list data
;***************
; list of moves to perform iterative deepening search on
ids-move-list: copy []

save-ids-move-list: func [
	list [block!]
][
	ids-move-list: copy list
]

order-ids-move-list: func [
	order-item [integer!]
	/desc
][
	either desc [
		order-moves-by-score/desc ids-move-list order-item
	][
		order-moves-by-score ids-move-list order-item
	]
]

read-ids-move-list: does [
	return ids-move-list
]

change-ids-move-list: func [
	idx [integer!]
	new-move [block!]
][
	ids-move-list/:idx: new-move
]

winning-moves-found: func [
	return: [logic!]
	/local
	value-pos [integer!]
	result [logic!]
][
	result: false
	if 0 = length? ids-move-list [return result]
	value-pos: length? ids-move-list/1
	forall ids-move-list [
		if INFINITY = ids-move-list/1/:value-pos [
			result: true
		]
	]
	return result
]

all-moves-lose: func [
	return: [logic!]
	/local
	value-pos [integer!]
	result [logic!]
][
	result: true
	if 0 = length? ids-move-list [return result]
	value-pos: length? ids-move-list/1
	forall ids-move-list [
		if MINUS-INFINITY < ids-move-list/1/:value-pos [
			result: false
		]
	]
	return result
]

single-playable-move: func [
	return: [logic!]
	/local
	value-pos [integer!]
	move [block!]
	count [integer!]
][
	if 0 = length? ids-move-list [return false]
	value-pos: length? ids-move-list/1
	count: 0
	ids-move-list: head ids-move-list
	until [
		move: first ids-move-list
		if MINUS-INFINITY < move/:value-pos [count: count + 1]
		ids-move-list: next ids-move-list
		any [	1 < count
				tail? ids-move-list]
	]
	ids-move-list: head ids-move-list
	either 1 = count [true][false]
]

;***************
; Book functions
;***************
lookup-opening-book: function [
	hash-value [string!]
	color [integer!]
	return: [block!]
	/local opening-result [block!]
][
	opening-result: copy []
	if  found? find opening-book hash-value [
		opening-result: select opening-book hash-value
		either color <> opening-result/1 [
			opening-result: copy []
		][
			opening-result: opening-result/2
		]
	]
	opening-result
]

;**************
; Sorting moves
;**************
order-moves-by-score: function [
	"insertion-sort"
	array-moves [block!]
	m [integer!]         ; which column to sort on, the last
	/desc
	/local i [integer!] j [integer!] n [integer!]
	move [block!]
	logic-sort [logic!]
][ 
	either logic! = type? array-moves/1/(m) [
		logic-sort: true
		forall array-moves [
			move: first array-moves
			either move/(m) [
				move/(m): 0
			][
				move/(m): 1
			]
		]
	][
		logic-sort: false
	]
	
	n: length? array-moves
	i: n - 1                                  ; start at end working to first item
	while [i >= 1][
		move: array-moves/:i
		j: i
		while [ all	[	n > j
						any [ all [	desc
									move/(m) < array-moves/(j + 1)/(m) ]
							  all [ not desc
									move/(m) > array-moves/(j + 1)/(m) ]]]
		][ 
			array-moves/:j: array-moves/(j + 1)
			j: j + 1
		]
		array-moves/:j: move
		i: i - 1
	]

	if logic-sort [	; now reset to logic values
		forall array-moves [
			move: first array-moves
			either 0 = move/(m) [
				move/(m): true
			][
				move/(m): false
			]
		]
	]

]

;***************
; Choosing moves
;***************
choose-move: function [
	"Choose moves from the openingbook, or other similar sources"
	found-moves [block!]
	return: [block!]
	/local a [integer!] total-chance [integer!] chosen-move [block!]
][
	chosen-move: copy []
	a: random 100
	total-chance: 0
	foreach [move value] found-moves [
		total-chance: total-chance + value
		if all [0 = length? chosen-move 
				a < total-chance        ][
			chosen-move: move
		]
	]
	if 0 = length? chosen-move [chosen-move: first found-moves]
	chosen-move
]

choose-move-from-list: function [
	"Choose moves from result of iterative deepening search"
	move-list [block!]
	return: [block!]
	/local a [integer!] chosen-move [block!] max-score [integer!]
	number-of-moves [integer!]
	random-move [integer!]
	choose-from-top [integer!]
][ 
	number-of-moves: length? move-list
	either 0 = number-of-moves [
		return ["Lost"]
	][
		either 1 = number-of-moves [
			return move-list/1
		][
			a: length? move-list/1
		
			; if there are moves with max score choose (randomly) from these moves
			max-score: move-list/1/:a
		
			; if there are only losing moves, choose from the best moves with longest non-losing series
			if max-score = MINUS-INFINITY [
				; on level a - 1 there could be more than 1 move with an equal score
				; as all moves are losing it does not really matter which one to choose, 
				; we could maybe try the move leaving the most complex position on the board making it 
				; harder to the opposite (human side) to find the winning move
				if a <= MOVE-ELEMENTS [ 
					; This was the only level before all moves faced a losing countermove
					; in no way this means a human will always find the winning move :-)
					random-move: random number-of-moves
					return move-list/:random-move
				]
				a: a - 1
				max-score: move-list/1/:a
				; because we use a backwards insertion sort the order of moves from the earlier sort is still present!
				; so the values are still ordered with the score in this position descending!
			]
			; now choose from top x best moves
			choose-from-top: 0

			; Sure not forget the all in this while ;-)
			while [	all [not tail? move-list
						move-list/1/:a = max-score] ][
				choose-from-top: choose-from-top + 1
				move-list: next move-list
			]
			move-list: head move-list ; set list back to head position
			random-move: random choose-from-top

			return move-list/:random-move
]	]	]

get-game-no-more-moves-value: does [
	INFINITY
]

;***************
; Seek algoritms
;***************
;****************************************************************
; Iterative Deepening Search
;****************************************************************
iterative-deepening-search: func [
	in-board [block!]
	color [integer!]
	requested-depth [integer!]
	return: [block!]
	/local depth [integer!]
	found-moves [block!]
	local-ids-move-list [block!]
	beta-cutoff [logic!]
][	

	if requested-depth > MAX-DEPTH [requested-depth: MAX-DEPTH]
	if 1 > requested-depth [requested-depth: 1]
	
	ids-hash-code: calculate-hash-code in-board

	if in-opening-book? [
		found-moves: lookup-opening-book ids-hash-code color
		either 0 < length? found-moves [
			return choose-move found-moves
		][
			in-opening-book?: false
		]
	]

	winning-moves-found?: single-playable-move?: false
	all-moves-lose?: max-calculation-time-used?: false
	variant: copy []
	depth: 0
	
	; Make the moves list that we need to keep the bookkeeping for best move
	local-ids-move-list: make-move-list in-board color
	save-ids-move-list local-ids-move-list
	if 0 < CHECK-INDICATOR [
		order-ids-move-list CHECK-INDICATOR
	]
	order-ids-move-list/desc MOVE-ELEMENTS

	; Now loop through increasing depths
	
	until [
		depth: depth + 1
		print ["increasing iterative deepening search depth from " depth - 1 "to " depth]
		either 2 < depth [beta-cutoff: true] [beta-cutoff: false]

		principal-variation-search in-board color alpha beta depth variant true beta-cutoff ; depth as current-depth, true to add the score to the move

		; Now order the moves using the value at given depth. The move itself has MOVE-ELEMENTS fields for the move description.
		;either all not max-calculation-time-used not user-forced-break 
		order-ids-move-list/desc MOVE-ELEMENTS + depth

		winning-moves-found?: winning-moves-found 
		all-moves-lose?: all-moves-lose
		single-playable-move?: single-playable-move
		
		any [
			depth >= requested-depth
			winning-moves-found?
			single-playable-move?
			all-moves-lose?
			max-calculation-time-used?
		]
	]
	
	choose-move-from-list ids-move-list
]

;******************************************
; "I can't stand pat" for quiescence-search
;******************************************
global-stand-pat: 0

set-stand-pat: func [
	set-value [integer!]
][
	global-stand-pat: set-value	
]

get-stand-pat: func [
	return: [integer!]
][
	global-stand-pat
]

;****************************************************************
; Principle Variation Search for fail hard
;****************************************************************
principal-variation-search: function [
	in-board [block!]
	color [integer!]
	alpha [integer!]
	beta [integer!]
	depth [integer!]
	variant [block!]
	base [logic!]
	beta-cutoff [logic!]
	return: [integer!]
	/local
	search-pv [logic!]
	i [integer!]
	j [integer!]
	piece-value [integer!]
	captured [integer!]
	pvs-move-list [block!]
	work-move-list [block!]
	move [block!]
	move-length [integer!]
	quiet-list [block!]
	result-block [block!]
	quiescence-result [integer!]
	idx [integer!]
	skip-to-next-move [logic!]
][
	if 0 = depth [
		; Required search depth is reached,
		; so not expanding into more moves by the current player
		; Is position quiet? We only want to enter quiescence search if necessary.
		
		; First we want to know if the position leaves us in a lost position
		quiescence-result: 0
		quiet-list: make-move-list in-board color
		
		either 0 = length? quiet-list [
			; opponent has not more moves, "we" won
			quiescence-result: MINUS-INFINITY
		][
			; play all moves from the quiet-list and see if we left a one move win situation
			; mate or pat in 1 move
			forall quiet-list [
				move: first quiet-list
 				; Play the move
				i: move/2
				j: move/3
				piece-value: in-board/:i
				in-board/:i: 0
				captured: in-board/:j
				in-board/:j: piece-value
				
				; Using anymoves? refinement returns a block with true or false in it.
				result-block: make-move-list/anymoves? in-board (1 - color)

				if 'false = result-block/1 [
					; there is a mate or pat move in this series of moves (for the opponent)
					quiescence-result: INFINITY
				]
				
				; Undo the move
				in-board/:i: piece-value
				in-board/:j: captured	
			]
		]
			
		if 0 = quiescence-result [
			; No result found, so enter the quiescence routine now
			quiescence-result: negate quiescence-search in-board 1 - color alpha beta
		]
		
		; Returning a value here. 
		; This may look strange at first but the calling PVS function knows how to deal with this.
		return quiescence-result  
	]

	; The search depth is larger than 0 from here
	search-pv: true

	either base [ ; Moves made in calling function, we can use a copy now
		pvs-move-list: read-ids-move-list
	][
		pvs-move-list: make-move-list in-board color
	]
	
	if 0 = length? pvs-move-list [
		; no moves found
		; for Xiangqi this means lost, for regular chess this could be pat, draw
		; so we use a function here to get the correct value for the game
		return get-game-no-more-moves-value
	]
	
	if 1 = length? pvs-move-list [
		; one move found, when in base call this will be the only move playable
		; if not this move may be in a better variant than another move so still search options.
		if base [
			; It is the only move, so any value between MINUS-INFINITY and INFINITY would do(?).
			; to be sure make it the evaluate value of the position
			; !!attention: this needs to be adjusted to the color and who is playing
			return evaluate-board in-board
		]
	]
	
	order-moves-by-score pvs-move-list CHECK-INDICATOR

	idx: 0
	forall pvs-move-list [
		idx: idx + 1
		; First get some information on the move
		move: first pvs-move-list
		move-length: length? move
		move-value: move/:move-length

		; Only do work on moves that do not have a losing score yet.		
		either MINUS-INFINITY < move-value [

			; Play the move
			i: move/2
			j: move/3
			piece-value: in-board/:i
			in-board/:i: 0
			captured: in-board/:j
			in-board/:j: piece-value

			variant: append/only variant move

			either search-pv [
				score: negate principal-variation-search in-board (1 - color) negate beta negate alpha (depth - 1) variant false beta-cutoff
			][
				score: negate principal-variation-search in-board (1 - color) negate (alpha - 1) negate alpha (depth - 1) variant false beta-cutoff
				if score > alpha [ ;  in fail-soft all [score > alpha  score < beta] is common
					score: negate principal-variation-search in-board (1 - color) negate beta negate alpha (depth - 1) variant false beta-cutoff ; re-search
				]
			]

			; Undo the move
			in-board/:i: piece-value
			in-board/:j: captured	

			; Program faced a beta cut-off on the base level
			skip-to-next-move: false
			; variant: head clear back tail variant
			if base [
				move: append copy move score
				change-ids-move-list idx move
			]
			; forall does not need a next to loop thru all possible values
			; test score
			;if score >= beta [
			if score > beta [ ; is this better??
				variant: head clear back tail variant
				; DO NOT CUT-OFF AT BASE LEVEL!!
				either any [not base
							beta-cutoff][
					return beta          	; fail-hard beta-cutoff
				][
					skip-to-next-move: true
				]
			]
			if not skip-to-next-move [
				if score > alpha [ ; Perhaps this should read if score >= alpha
					alpha: score			; alpha acts like max in MiniMax
					search-pv: false  		; it is recommend to set search-pv outside the score > alpha condition.
				]
			]
			variant: head clear back tail variant
		][	
			; score is another MINUS-INFINITY
			append move MINUS-INFINITY
			change-ids-move-list idx move		
		]
	]
	return alpha                    ; fail-hard
]

;****************************************************************
; Quiescence Search
;****************************************************************
quiescence-search: function [
	"this function checks if possible countercaptures balance out the last move"
	in-board [block!]
	color [integer!]
	alpha [integer!]
	beta [integer!]
	return: [integer!]
	/local
	stand-pat [integer!]
	score [integer!]
	qs-captures-list [block!]
	capturemove [block!]
	i [integer!]
	j [integer!]
	piece-value [integer!]
	captured [integer!]
][
	; !!attention will this be dependend on color and player.
	stand-pat: evaluate-board in-board
	if color = 1 [stand-pat: negate stand-pat]

	qs-captures-list: copy [] 
	qs-captures-list: make-move-list/capture in-board 1 - color

	; It can be that there are no playable moves left
	either 0 = length? qs-captures-list [
		; Are there still normal moves possible, if not this position is lost
		either not generator-found-moves? [
			; No possible moves, so lost position
			alpha: MINUS-INFINITY
		][
			alpha: stand-pat
		]
	][ ; This should be done after there has been checked if the position is lost
		if stand-pat >= beta [
			return beta
		]
		if alpha < stand-pat [
			alpha: stand-pat
		]
	]

	score: 0

	; If the length of the capture-list was 0, we will be at the tail of the series
 	while [not tail? qs-captures-list][

		; Play capturemove, testing validity is not needed because that was already done
        capturemove: first qs-captures-list
		i: capturemove/2
		j: capturemove/3
		piece-value: capturemove/1
		in-board/:i: 0
		captured: capturemove/4
		in-board/:j: piece-value

        score: negate quiescence-search in-board (1 - color) negate beta negate alpha

        ; Undo capturemove
		in-board/:i: piece-value
		in-board/:j: captured		

		if score >= beta [
			return beta
		]
        if score > alpha [
        	alpha: score
		]

		;every_capture_has_been_examined
		qs-captures-list: next qs-captures-list
    ]

	return alpha
]