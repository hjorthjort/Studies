<link href="/Users/hjort/Code/configs/markdown.css" rel="stylesheet"></link>

# Workers

[Wikipedia](https://en.wikipedia.org/wiki/Thread_pool)

##Problem

How do we find a concurrency sweet spot? Not too many threads (since threads
are expensive) and not too few, because that would mean we loose the
opportunity of some concurrency.

## Solution

Fix a number of *worker threads*. This is a pool of threads that can run a
specified function. The size of the pool is fixed (generally it is optimized
for the system). Workers take a function that they perform.

We generally keep these worker threads in two pools: active and passive
threads. If we want concurrency, instead of starting a new thread we call a
worker. If there are available (passive) workers, one of these will take our
task. If none is available, our job will wait until there is available worker.

# Avoiding deadlock when there are many locks

Establish a global order in which to acquire locks whenever a process wants to
acquire many locks.

For example, we have lock, A, B, C, and D. We establish order:

>    A > B > C > D

When process P wants to acuire lock C and A, and Q wants to acuire B, C and D,
they must acquire in order (in alphabetic order in this case), and release in
reverse order.

    P
    ----
    acquire(A)
    acquire(C)
    //Do stuff
    release(C)
    release(A)

    Q
    ----
    acquire(B)
    acquire(C)
    acquire(D)
    //Do stuff
    release(D)
    release(C)
    release(B)

Now the threads can't deadlock, since any thread that wants two locks must
acquire them in order, and no two threads can be waiting for each other while
locking.

# Software Transactional Memories (STM)

## Problem

Suppose you have two thread safe buffers and you want to atomically take an
element from one of them and put it in the other. You can lock *both* buffers
when doing it. But this requires a lot of lock handling which can lead to
errors.

*Pessimistic* concurrency is when we always assume that we have to enforce
mutex by locking down our critical section.

## Solution

STM is a form of *optimistic* concurrency, which follows this algorithm:

1. Assume we have mutal exclusion.
2. Perform our critical section.
3. Check that everything went okay.
4. If not, revert and try again. Otherwise, proceed.

It's like working on a scratchpad based on the previous state. If, when we
finished on the scratchpad and nothing has changed in the state we care about,
we transfer the content from our scratchpad. However, if seomthing changed, we
tear of the page, crumple it and restart.

STM is something operating system builders and language implementers worry
about, not programmers.

STM allows lock-free programming. *NB: The locks are there, but abstracted away
for the programmer*.

### Vocabulary is database-ish

* Commit (save changes)
* Revert/rollback/retry (scratch and redo)

## Drawbacks of transactions

Cannot guarantee fairness.

A large transaction can be starved by many small ones
All the book keeping can be expensive.

STM are still a subject of reseach!
