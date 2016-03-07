<meta charset='utf8'>
<link href="/Users/hjort/.markdown.css" rel="stylesheet"></link>
#Questions

## Part 2

What is up with the statements p3 and q3? Is it supposed to be an || (or)?
Otherwise this does not make any sense.

## Part 3

In the scond version of the code (the consultant's code), what are they
locking? Account objects? There is no lock method on these. Should it be
`store[source].l.lock()`, perhaps?

Exam ====

Tail recursive --------------

For a function to be tail recursive, it is necessary that *every* recursive
call in the function is 1) the last call in that sequence of the function and
2) is standalone, so that nothing else happens but the call.

Not tail-rec:

    func() -> 1 + func().

    func2() -> func2(), 1.

Tail-rec:

    func() -> 1 + foo(), func().

    func2() -> A = 1, func2().

Busy waiting ------------

### 1.5

Yes, this is busy waiting. Why? Because the loop can keep running many times
w/o anything meaningful being accomplished.

### 1.6

This is not busy waiting, obv.

### 1.7

Differences between `synchronized` and `java.util.concurrent`-locks:

MAKE INTO A TABLE
* Java 5 monitors has tryLock 
    * and lockInterruptibly
* More than one condition variable
* Automatic exception handling
* `synchronized` can only be perfomred in code blocks, whereas Java 5 monitors can be held between methods and so forth.
* Lock can be fair


| `synchronized`               | Java 5 monitors                  |
|------------------------------|----------------------------------|
| no such construct            | tryLock()                        |
| -                            | lockInterruptibly                |
| can't be fair                | can be fair                      |
| only one condition variable  | many condition variables         |
| automatic exception handling | need try/catch/finally           |
| only in {} code blocks       | cna be passed around more freely |
