def generate(p):
    for k in range(1,p):
        yield find_cyclic(k, p)

def find_cyclic(k, p):
    a = k
    ret = [k]
    while (a > 1):
        a = (a * k) % p
        ret.append(a)
    return ret

def print_generators(p):
    gen = [cyc for cyc in generate(p) if len(cyc) == p - 1]
    # Transpose
    gen = [[gen[i][j] for i in range(len(gen))] for j in range(p-1)]
    i = 0
    for cyclic in gen:
        i += 1
        print(("a^%-2d: & " % i)
              + (("%2d & " * len(gen[0]))[:-2] + "\\\\") % tuple(cyclic))

print_generators(11)
