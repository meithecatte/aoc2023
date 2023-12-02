#!/usr/bin/env -S sed -Enf
/\d{3} [rgb]/s/^.*$/0/g
/[2-9][0-9] [rgb]/s/^.*$/0/g
/1[3-9] red/s/^.*$/0/g
/1[4-9] green/s/^.*$/0/g
/1[5-9] blue/s/^.*$/0/g
s/^Game ([0-9]+): .*$/\1/g
: convert
    s/^(a*)0/\1\1\1\1\1\1\1\1\1\1/g
    s/^(a*)1/\1\1\1\1\1\1\1\1\1\1a/g
    s/^(a*)2/\1\1\1\1\1\1\1\1\1\1aa/g
    s/^(a*)3/\1\1\1\1\1\1\1\1\1\1aaa/g
    s/^(a*)4/\1\1\1\1\1\1\1\1\1\1aaaa/g
    s/^(a*)5/\1\1\1\1\1\1\1\1\1\1aaaaa/g
    s/^(a*)6/\1\1\1\1\1\1\1\1\1\1aaaaaa/g
    s/^(a*)7/\1\1\1\1\1\1\1\1\1\1aaaaaaa/g
    s/^(a*)8/\1\1\1\1\1\1\1\1\1\1aaaaaaaa/g
    s/^(a*)9/\1\1\1\1\1\1\1\1\1\1aaaaaaaaa/g
t convert
H
$ {
    x
    s/\n//g
    : decimalize
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
    t decimalize
    p
}
