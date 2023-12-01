#!/usr/bin/env -S sed -Enf
: munch_front
s,^one,1,g
s,^two,2,g
s,^three,3,g
s,^four,4,g
s,^five,5,g
s,^six,6,g
s,^seven,7,g
s,^eight,8,g
s,^nine,9,g
s,^[^0-9],,g
t munch_front

: munch_back
s,one$,1,g
s,two$,2,g
s,three$,3,g
s,four$,4,g
s,five$,5,g
s,six$,6,g
s,seven$,7,g
s,eight$,8,g
s,nine$,9,g
s,[^0-9]$,,g
t munch_back

s,[^0-9],,g
s,^(.).*(.)$,\1\2,g
s,^.$,&&,g
s,.,&&&&&&&&&&,
s,0,,g
s,1,a,g
s,2,aa,g
s,3,aaa,g
s,4,aaaa,g
s,5,aaaaa,g
s,6,aaaaaa,g
s,7,aaaaaaa,g
s,8,aaaaaaaa,g
s,9,aaaaaaaaa,g
H
$ {
    x
    s,\n,,g
    : convert
    s,a{10},b,g
    s,^(b*)(a*)([0-9]*)$,\1z\2\3,g
    s,za{9},9,g
    s,za{8},8,g
    s,za{7},7,g
    s,za{6},6,g
    s,za{5},5,g
    s,za{4},4,g
    s,za{3},3,g
    s,za{2},2,g
    s,za{1},1,g
    s,z,0,g
    t ok
    : ok
    s,b,a,g
    t convert
    p
}
