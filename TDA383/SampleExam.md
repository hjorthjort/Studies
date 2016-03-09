<meta charset='utf8'>
<link href="/Users/hjort/.markdown.css" rel="stylesheet"></link>
#Questions

## Part 2

What is up with the statements p3 and q3? Is it supposed to be an || (or)?
Otherwise this does not make any sense.

> If one or more processes are in the pre-protocol, then one of them will succeed.

## Part 3

In the scond version of the code (the consultant's code), what are they
locking? Account objects? There is no lock method on these. Should it be
`store[source].l.lock()`, perhaps?

Exam
====

Tail recursive 
--------------

For a function to be tail recursive, it is necessary that *every* recursive
call in the function is 1) the last call in that sequence of the function and
2) is standalone, so that nothing else happens but the call.

Not tail-rec:

    func() -> 1 + func().

    func2() -> func2(), 1.

Tail-rec:

    func() -> 1 + foo(), func().

    func2() -> A = 1, func2().

Busy waiting 
------------

### 1.5

Yes, this is busy waiting. Why? Because the loop can keep running many times
w/o anything meaningful being accomplished.

### 1.6

This is not busy waiting, obv.

### 1.7

Differences between `synchronized` and `java.util.concurrent`-locks:

| `synchronized`               | Java 5 monitors                  |
|------------------------------|----------------------------------|
| no such construct            | tryLock()                        |
| -                            | lockInterruptibly                |
| can't be fair                | can be fair                      |
| only one condition variable  | many condition variables         |
| automatic exception handling | need try/catch/finally           |
| only in {} code blocks       | cna be passed around more freely |

State spaces
------------

### 2.6

State it formally for *this particular program*. Use the state names given to
describe it.

> If one or more processes are in the pre-protocol, then one of them will succeed.
> If only one is in the pre-protocol, then it must succeed.

### 2.7

Prove this by showing that from every state where p2, p3, q2 or q3 is part of
the state, one of the processes progresses.

### Invariants

Check that for every state corresponding to the LHS, the statement on the RHS
is true.

Concurrency in Java
-------------------


