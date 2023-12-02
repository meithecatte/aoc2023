variable #r
variable #g
variable #b
variable total  0 total !

: reset ( v -- ) 0 swap ! ;
: max! ( n v -- ) tuck @ max swap ! ;
: start-game #r reset #g reset #b reset ;
: parse-index ( -- d ) 0. [char] : parse >number 2drop d>s ;

: red   #r max! ;  : red,   red ;    : red; red ;
: green #g max! ;  : green, green ;  : green; green ;
: blue  #b max! ;  : blue,  blue ;   : blue; blue ;

: power ( -- n ) #r @ #g @ #b @ * * ;
: finish-game  power total +! ;

: Game finish-game start-game parse-index drop ;
require input

finish-game
total @ . cr
bye
