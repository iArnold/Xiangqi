# Xiangqi

Xiangqi in Red (Version 0.6.0!)
-------------------------------

The game of Xiangqi programmed using the programming language Red.
The program is reported not to work with the new version of Red, version 0.6.1.
I updated the bindings to the most recent available (05-06-2016) but this is no guaranty it will work now.
At the moment I have no intention to update for every upgrade of Red, for that takes too much of my time.

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

Note
----
Please be aware of the fact that Red is still in PRE-alpha stage (version 0.6.0) at time 
of writing this code. Above that, my code is not always the best way of writing Red code.
The code could be improved for speed, readability, structure, be more Red (REBOL like), 
my main concern here has been to create a working program that is human readable.

Documentation
-------------

Documentation explains how the internal representation of the board, the pieces and the
moves came to be as they are.

Red version
-----------

The console program was made using the 0.5.4 version of the Red programming language.
Therefore also the bindings by Kaj de Vos, included here in the bind folder, are the 
corresponding files for this Red version also. When updating to a next version of Red, 
the bindings should be upgraded as well. The original bindings by Kaj de Vos can be 
found here 

	http://red.esperconsultancy.nl/Red-test 

The GUI version of the program, xiangqi-board.red, is made with the development version 
of Red 0.6.0.
Bad news, good news follows now. The GUI is only for Windows. The good news is Red
language is also aiming to target all kinds of other platforms too in a native way.
If you want to help get Red have a GUI on your favorite platform, please feel free to 
do so.

Compiling this program
----------------------

To compile this program, you will need the sourcecode, a Rebol (View) program for your 
computer and the Red sources. Because the GUI branch has been merged into the master 
branch you can now use the sources from the master branch. 
You can find very specific information how to compile Red programs on the Github site of 
Red here: 

	https://github.com/red/red

In short it is start your Rebol View program, go to the console and change directory 
to the Red source folder 

	cd red

and do

	do %red.r
	rc %../xiangqi/xiangqi/xiangqi-console.red

Note that I have renamed the folder Xiangqi-master you get when unpacking the 
Xiangqi-master.zip file you downloaded to Xiangqi, I also like to rename Red-master folder
to just Red folder.
And now the Red compiler will create your program in the Red folder.

Compiling the GUI version is done by

	rc %../xiangqi/xiangqi/xiangqi-board.red

You will notice this opens a command window as well. This is handy for trying out 
improvements, it will show all print and probe debugging helper commands you have put 
inside your changed code.
If you do not want such a command window to appear you compile using

	do/args %red.r "-c -t Windows %../xiangqi/xiangqi/xiangqi-console.red"

Because the program needs to load the images for the pieces you must make sure the folder
the program is in contains the images folder and images. (Or you copy the program from the
Red folder over to the Xiangqi/xiangqi folder

Testprograms
------------

The program comes including some small testprograms that can be compiled using Red too.

What is there to be done?
-------------------------

A lot! 


        The program needs much more testing than I have already done. 
        Add list for played moves.
        Undo functionality for moves.
        Show the best variant considered.
        Making use of computed hashes for each position to save time on computing a position
            that was already done, when a different order of moves was played. 
            This can make a HUGE improvement in speed!
        Better evaluation by making use of influence data and pins.
        Making use of different fail hard and fail soft mechanisms.
        Improve quiescence routine to include moves that give check.
        Include rules for draw when repetitive moves are made by the players.
        Make program compatible to compete against other chess programs.
        Create a version for the next release of Red. 
        Make more use of faster Red/System routines.
        Make use of general move databases.
        Check and improve the hash used. I have the idea that the hash code can be shortened,
            but I am not 100% sure about that. (Only partly possible.)
        Add file I/O to export played games and import new positions. (Wait for Red I/O).
	
I never played an actual game of Xiangqi in my life, yet I made this program. If you like 
Xiangqi, know just a bit of programming, or like this project, please let me know and 
join in making this program better. 

License
-------------------------
See license document. The binding files by Kaj de Vos have their own license, included as 
well. In short you use the provided software as is, at your own risk.
