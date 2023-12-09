import re
from math import lcm
def doit(graph, loop, start, is_end):
    steps = 0
    pos = start
    while not is_end(pos):
        step = loop[steps % len(loop)]
        steps += 1
        if step == 'L':
            pos = graph[pos][0]
        else:
            pos = graph[pos][1]
    return steps
def solve(filename):
    print(filename)
    with open(filename) as f:
        inp = f.read().strip().split('\n')
    loop = inp[0]

    graph = {}
    for line in inp[2:]:
        m = re.match(r"(\w+) = \((\w+), (\w+)\)", line)
        graph[m.group(1)] = (m.group(2), m.group(3))

    if 'AAA' in graph:
        print('part 1:', doit(graph, loop, 'AAA', lambda pos: pos == 'ZZZ'))

    p2 = 1
    for start in graph:
        if not start.endswith('A'): continue
        p2 = lcm(p2, doit(graph, loop, start, lambda pos: pos.endswith('Z')))
    print('part 2:', p2)

solve('input.example')
solve('input.example2')
solve('input.example3')
solve('input')
