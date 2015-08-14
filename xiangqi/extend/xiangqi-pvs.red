Red [
	"Principle Variantion Search for Chess Games"
	filename: %xiangqi-pvs.red
	author:   "Arnold van Hofwegen"
	version:  0.1
	date:     "25-Mar-2015"
	needs:    "Red 0.5.1"
]
;****************************************************************
; Routines Principle Variation Search for fail hard and fail soft
;****************************************************************
;principal-variation-search: :principal-variation-search-fail-hard
;principal-variation-search: :principal-variation-search-fail-soft
;principal-variation-search: :pvs-fail-hard
;principal-variation-search: :pvs-fail-soft

;****************************************************************
; Principle Variation Search for fail hard
;****************************************************************
; Temp put back in best-move so compare with that before using this
principal-variation-search-fail-hard: function [
	in-board [block!]
	color [integer!]
	alpha [integer!]
	beta [integer!]
	depth [integer!]
	variant [block!]
	base [logic!]
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
	quiescence-result [integer!]
	idx [integer!]
][
	if debug [
		print "function: principal-variation-search fail hard"
		print ["color:" color]
		print ["depth:" depth]
		print ["Alpha:" alpha]
		print ["Beta :" beta]
	]
	
	if 0 = depth [
		if logging [
			add-log-data "Quiescence search for variant"
			add-log-data form variant
		]
		; Required search depth is reached,
		; so not expanding into more moves by the current player
		quiescence-result: quiescence-search in-board color alpha beta
		return quiescence-result  
	]

	search-pv: true

	either base [ ; Moves made in calling function, we can use a copy now
		pvs-move-list: read-ids-move-list
	][
		pvs-move-list: make-move-list in-board color
	]
	
	if 0 = length? pvs-move-list [
		; no moves found
		return MINUS-INFINITY ; lost
	]
	
	if 1 = length? pvs-move-list [
		; one move found, when in base call this will be the only move playable
		; if not this move may be in a better variant than another move so still search options.
		if base [
			return 1 ; It is the only move so any value between MINUS-INFINITY and INFINITY would do.
		]
	]
	
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
				if debug [print "search-pv"]
				score: negate principal-variation-search-fail-hard in-board 1 - color negate beta negate alpha depth - 1 variant false
			][
				if debug [print "not search-pv"]
				score: negate principal-variation-search-fail-hard in-board 1 - color negate (alpha - 1) negate alpha depth - 1 variant false
				if score > alpha [ ; in fail-soft ... && score < beta  is common practise
					print "score > alpha"
					score: negate principal-variation-search-fail-hard in-board 1 - color negate beta negate alpha depth - 1 variant false ; re-search
				]
			]

			; Undo the move
			in-board/:i: piece-value
			in-board/:j: captured	

			; variant: head clear last variant
			if base [
				move: append copy move score
				change-ids-move-list idx move		
			]
			; forall does not need a next to loop thru all possible values
			; test score
			if score >= beta [
				if logging [
					add-log-data "Fail hard Beta-cut-off"
					add-log-data form variant
					add-log-data form reduce ["Beta: " beta "Score: " score]
				]
				variant: head clear last variant
				return beta          	; fail-hard beta-cutoff
			]
			if score > alpha [ ; Perhaps this should read if score >= alpha
				if logging [
					add-log-data "Improved score found"
					add-log-data form variant
					add-log-data form reduce ["Alpha: " alpha "Score: " score]
				]
				alpha: score			; alpha acts like max in MiniMax
				search-pv: false  		; it is recommend to set search-pv outside the score > alpha condition.
			]
			variant: head clear last variant
		][	
			; score is another MINUS-INFINITY
			append move MINUS-INFINITY
			change-ids-move-list idx move		
		]
	]
	return alpha                    ; fail-hard
]

;****************************************************************
; Principle Variation Search for fail soft
;****************************************************************
;Call from root:
; 
;rootscore: principal-variation-search-fail-soft MINUS-INFINITY INFINITY depth

principal-variation-search-fail-soft: function [
	in-board [block!]
	color [integer!]
	alpha [integer!] 
	beta [integer!]
	depth [integer!]
	return:  [integer!]
	/local 
	score [integer!] 
	bestscore [integer!]
][
	if debug [
		print "function: principal-variation-search fail soft"
		print ["color:" color]
		print ["depth:" depth]
		print ["Alpha:" alpha]
		print ["Beta :" beta]
	]
	
	if depth <= 0 [
		; Search depth is reached, so not expanding into more moves by the current player
		return quiescence-search in-board color alpha beta
	]
 
	; using fail soft with negamax:
	; Play first move
	
	bestscore: negate principal-variation-search-fail-soft in-board 1 - color negate beta negate alpha depth - 1
	; Undo first move

	if bestscore > alpha [
		if bestscore >= beta [
			return bestscore
		]
		alfa: bestscore
	]
 
	forall remaining moves [
		make move
		; Here call the alpha-beta or zero-window-search function
		score: negate principal-variation-search-fail-soft in-board 1 - color negate (alpha + 1) negate alpha depth  - 1 
		if all [score > alfa
      			score < beta ][
			; research with window [alfa beta]
			score: negate principal-variation-search-fail-soft in-board 1 - color negate beta negate alpha depth - 1
			if score > alfa [
				alfa: score
			]
		]
		unmake move
		if score > bestscore [
			if score >= beta [
        		return score
         	]
         	bestscore: score
		]
	]

	return bestscore
]