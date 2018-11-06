import time

def profile(f, xs, numRuns):
    start_time = time.time()
    for n in range(numRuns):
        f(*xs)
    end_time = time.time()
    return end_time - start_time
