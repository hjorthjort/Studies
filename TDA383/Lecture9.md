# Parallelism, Workers, and Introduction to Software Transactional Memories

Up until the early 2000's, you didn't have to rewrite your programs, they would get a lot faster every year anyway.

Today, clock speeds don't increse, and not performance per clock speed. Transistors still increase.

(Clock speeds are not increasing because we have reached a practical limit for how much power we can supply processors and still keeping them cool).

> More transistors + same clockspeeds => more cores.

## Tuning your applicaton

Never do microoptimization. Find the large bottlenecks.

> We should forget about small efficiencies, say about 97% of the time: premature optimization is the root of all evil. **Yet we should not pass up our opportunities in that critical 3%** - Donald Knuth

## Parallelizing computations

Parallel problems that are very easy to parrallelize are called **embarassingly parallel**.

> In parallel computing, an embarrassingly parallel workload or problem (also called perfectly parallel or pleasingly parallel) is one where little or no effort is needed to separate the problem into a number of parallel tasks. This is often the case where there is little or no dependency, or need for communication between, those parallel tasks, or for results between them.

Associative operations such as add(X, Y), max(X,Y), etc, are generally very easy to parallelize.

## Q&A on the Lab

* When a message arrives it should be passed to all users in that chat room. This is done by keeping their PID:s and sending messages to their genservers.

<link href="/Users/hjort/Code/configs/markdown.css" rel="stylesheet"></link>
