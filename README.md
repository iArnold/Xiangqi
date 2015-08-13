# Xiangqi

Xiangqi in Red
--------------

The game of Xiangqi programmed using the programming language Red.

What is the Red programming language?
-------------------------------------

Red is a new programming language ( http://www.red-lang.org ) 
heavily inspired by REBOL ( http://www.rebol.com ).

Why use Red as programming language?
------------------------------------

Because code written in Red means that the source of this program will be very readable, 
unlike similar open sourced chess programs that use C or C++ and contain functions with 
cryptic short names like 'D' and 'S'. Generally the existing chess programs if they are
open sourced at all, are hard to follow because of their effective use of the internal 
computer memory and there will be a lot of binary calculations happening. Calculations 
that mean very little to people trying to understand what is going on.

The Red program for Xiangqi will make use of a human understandable representation of the 
chessboard and the code that works on it will be better understandable as a consequence.

But ultimately because programming using Red is programming with FUN.

Red version
-----------

This program was made using the 0.5.4 version of the Red programming language.
Therefore also the bindings by Kaj de Vos, included here in the bind folder, are the 
corresponding files for this Red version also. When updating to a next version of Red, 
the bindings should be upgraded as well. The original bindings by Kaj de Vos can be 
found here http://red.esperconsultancy.nl/Red-test 

Compiling this program
----------------------

To compile this program, you will need the sourcecode, a Rebol (core) program for your 
computer and the Red sources. You can find very specific information how to compile Red
programs on the Github site of Red here: https://github.com/red/red
In short it is start your Rebol core program, change directory to the Red source folder 
	cd red
and do
	do %red.r
	rc %../xiangqi/xiangqi/xiangqi-console.red
And Red will create your program in the Red folder.

Testprograms
------------

The program comes including some small testprograms that can be compiled using Red too.

What is there to be done?
-------------------------

A lot! 
	The program needs much more testing than I have already done. 
	Undo functionality for moves.
	Show the best variant considered.
	Making use of computed hashes for each position to save time on computing a position
		that was already done, when a different order of moves was played. 
	Better evaluation by making use of influence data
	Making use of different fail hard and fail soft mechanisms
	Improve quiescence routine to include move that give check
	Include rules for draw when repetitive moves are made by the players
	Make program compatible to compete against other chess programs
	Create a version for the next release of Red  
	Make use of general move databases
	Check and improve the hash used. I have the idea that the hash code can be shortened,
		but I am not 100% sure about that.

Please do not count on me to fill in all the blancs here. I never played an actual game of 
Xiangqi in my life! 

License
-------------------------
See license document. The binding files by Kaj de Vos have their own license, included as 
well. In short you use the provided software as is, at your own risk.
