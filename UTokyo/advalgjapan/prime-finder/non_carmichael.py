import random, math
from gcd import gcd

# Returns if p is prime with confidence `conf`.
# Always accurate for prime numbers.
# Confidence is only valid for non-Carmichael numbers. (Why is that?)
def isPrimeWithConfidence(p, conf):
    times = 1 / (1 - conf)
    for i in range(math.ceil(times)):
        if not isPrime(p):
            return False
    return True

def isPrime(p):
    a = random.randint(1, p-1)
    if gcd(p, a) != 1:
        return False
    return (a ** (p - 1)) % p == 1
