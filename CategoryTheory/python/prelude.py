def identity(fun):
    return fun

def compose(g, f):
    # g after f.
    tmp = lambda x : g(f(x))
    return tmp

def memoize(f):
    table = {}
    def memoized_f(*args):
        if args in table:
            return table[args]
        result = f(*args)
        table[args] = result
        return result

    return memoized_f

