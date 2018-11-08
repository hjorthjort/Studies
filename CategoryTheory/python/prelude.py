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

class Optional:
    _value = None

    def __init__(self, x = None):
        self._value = x

    def __str__(self):
        if self.is_valid():
            return "just " + str(self.value())
        return "nothing"

    def nothing():
        return Optional()

    def just(x):
        return Optional(x)

    def is_valid(self):
        return self._value is not None

    def value(self):
        return self._value

    def compose(f, g):
        def temp(x):
            opt = f(x)
            if opt.is_valid():
                return g(opt.value())
            return opt  # It must be invalid.
        return temp


