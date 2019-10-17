
# Euclid. A and B must be ints.
def gcd(a, b):
    q = a // b
    r = a % b
    if r == 0:
        return b
    return gcd(b, r)
