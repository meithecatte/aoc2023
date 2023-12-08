def doit(t, d):
    ok = 0
    for hold in range(t + 1):
        d_went = hold * (t - hold)
        if d_went > d:
            ok += 1
    return ok
def solve(path):
    with open(path) as f:
        inp = f.read()
    time, distance = [list(map(int, x.split()[1:])) for x in inp.strip().split('\n')]
    print(path)
    ways = 1
    for t, d in zip(time, distance):
        ways *= doit(t, d)
    print(ways)
    t, d = [int(''.join(x.split()[1:])) for x in inp.strip().split('\n')]
    print(doit(t, d))

solve('input.example')
solve('input')
