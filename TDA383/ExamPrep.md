<link href="/Users/hjort/Code/configs/markdown.css" rel="stylesheet"></link>

For a great overview of what should be practiced, see the [repetition
lecture](http://www.cse.chalmers.se/edu/year/2015/course/TDA383/lecture11.html)

# Concepts

## Atomic primitives

### Comapare-and-swap (CAS)

        static int compare-and-swap(int ref common, int old, int new) {
         <int temp = common;
          if (common == old) common = new;
          retutn temp;>
        }    

### Test-and-set
        static void test-and-set(int ref common, int local) {
            <local = common;
            common = 1;>
        }

### Load-link/store-conditional (LL/SC)

describe it

## Concurrency models

### Lock based

Classical

#### Lock based programming in Java

Two types of monitors: `synchronized` and `ReentrantLock` (aka Java 5 monitors).

`synchronized` is simpler. `ReetrantLock` offers:

* More than one condition per monitor (`synchronized` only offers `wait`/`notify`, which is a single condition).
* Fairness. You can make `ReentrantLock` fair. This gurantess no starvation, but hurts performance.
* Timeouts while waiting
* `tryAcquire` might be seen as a subset of timeouted waiting: immediate timeout.
* Ability to check if a lock is being held.

### Message passing

Erlang model

### Software Transactional Memory (STM)

describe it

### Server-client

Very similar to a monitor. Many clients (which are like threads) using a shared
resource, the server

### Workers

* Tasks must be independent.
* Typically only a few of the tasks run at the same type.
* Too few means lack of concurrency opportunities
* Too many means high memory usage, context switching, threads paging Memory very fast.

# Problems that can be solved

* Dining philosophers
* Readers and writers
* Implementing semaphores with monitors
* Implementing monitors with sempahores
* Implementing multiple monitors with multiple conditions with a single monitor
  with a single condition.
* Implementing monitors using compare-ans-swap

# Solutions and algorithms

* Petersons' algorithm
* 

# Problems created by concurrent programs

* Corruption (safety violation)
    * Forgetting to lock
    * Race conditions
* Sequential bottlenecks
    * Holding too many locks
    * Contention points
    * Inherent bottle-necks
    * Threads competing for bandwidth
* Deadlocks
    * ... and unnecessary delays
* Starvation
* STM helps with deadlocks and corruption, but can lead to horrible starvation.

# Establishing correctness

Can be very difficult.

## Properties

### Safety

Is verified by a state diagram. Select all unsafe states, then backtrack from
them and prove that they don't connect to a reachable state.

### Liveness

#### No-Deadlock

Is verified by showing via state diagram that from every state that is
reachable, there is path for at least one thread to enter the critical section
in the future.

#### No-Starvation

Is verified by showing that from every reachable state for any thread, it will
eventually execute the critical section. Often requires some sort of
requirement, for example that a sempahore is fair.

## State diagrams

Work well when there are very few possible states.

## Invariants

Helps to limit state diagrams. Lets you prove correctness by showing that a state is only reachable from states which violate an invariant.
