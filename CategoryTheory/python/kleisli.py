from prelude import Optional
from math import sqrt

def safe_root(x):
    if x < 0:
        return Optional.nothing()
    return Optional.just(sqrt(x))

def safe_reciprocal(x):
    if x == 0:
        return Optional.nothing()
    return Optional.just(1/x)

safe_root_reciprocal = Optional.compose(safe_root, safe_reciprocal)

