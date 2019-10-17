import sys, inspect, datetime

# Classes under test.
import gcd
import non_carmichael as nc

def testGcd():
    assert gcd.gcd(10, 100) == 10
    assert gcd.gcd(99, 100) == 1
    assert gcd.gcd(12433141, 941243124) == 1
    assert gcd.gcd(1, 3) == 1
    assert gcd.gcd(2, 3) == 1

def testIsPrime():
    # Gathered from WolframAlpha
    primes = [ 199, 929, 677, 541, 743, 349, 409, 3, 379, 853 ]
    for p in primes:
         assert nc.isPrime(p), p

def testIsPrimeWithConfidence():
    # Gathered from WolframAlpha
    primes = [ 199, 929, 677, 541, 743, 349, 409, 3, 379, 853 ]
    for p in primes:
        assert nc.isPrimeWithConfidence(p, 0.9), (p, 0.9)
    nonPrimes = [ 195, 930, 1001]
    for p in nonPrimes:
        assert not nc.isPrimeWithConfidence(p, 0.99), (p, 0.99)

def testIsPrimeWithCarmichaelNumbers():
    carMs = [ 1155, 561, 10585 ]
    for p in carMs:
        assert not nc.isPrimeWithConfidence(p, 0.99), (p, 0.99)

# Testing that all tests get run.
wasRun = [ False for x in range(3) ]
def aTestTesting():
    assert False

def aTestTest():
    wasRun[0] = True
def aTestteSt():
    wasRun[1] = True
def tEstTrumpt():
    wasRun[2] = True

for (name, f) in inspect.getmembers(sys.modules[__name__], inspect.isfunction):
    if (name[-4:].lower() == "test" or name[0:4].lower() == "test"):
        print("Running: " + name + "...")
        f()
print("Finished: " + str(datetime.datetime.now()))
assert all(wasRun)
