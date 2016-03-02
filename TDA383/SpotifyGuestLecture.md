<link href="/Users/hjort/Code/configs/markdown.css" rel="stylesheet"></link>

# Spotify Guest Lecture

We are no longer getting faster CPU:s, just more of them.

> Intel has given up on Moore's Law!

## Optimizing

It is possible to figure out how to maximize branch prediction (in the CPU) and
to optimize how caches are used.

### Branch prediction

If we have a bunch of 64-bit memory elements that we are reading from memory ...

    E E E E E
    E E E E E
    E E E E E
    E E E E E

and we read them sequentially ...


    E -> E -> E -> E -> E
    -> E -> E -> E -> E -> E
    -> E -> E -> E -> E -> E
    -> E -> E -> E -> E -> E

then we can make branch prediction, and put the next elements in the cahce.

#### Lists

Linked List give you random access to memory places. ArrayList gives you a
single piece of memory to work with.

> For Java 10, it's proposed to have value object, which makes sure that
> **objects** in an array will actually be placed in sequential memory, rather
> than just putting their pointers in an array. This is complicated but would
> give great performance improvements.

## Spotify concurrency

Avoiding locks. 

### On CPU level

RMW on the CPU level, as well as CAS. This is actually implemented in Java
AtomicInteger and AtomicLong.

Example from AtomicInteger:

    public final int getAndIncrement() {
       for (;;) {
           int current = get();
           int next = current + 1;
           if (compareAndSet(current, next))
               return current;
       }
    }

Java has a very well defined memory model, which allows us to optimize a lot.

## Threads

Can be written asyncronously, so that they communicate with messages, in Java.
Erlang made it popular.

Reactive programming has become very popular.

Threads are vary expensive to create, and also to maintain. A server like the
one on Spotify that handle s metadata gets a *shit load* of requests all the
time. A standard implementation would be to spin up one thread per client. This
can become a bottleneck when we have thousands of requests – how fast we can
create threads is the bottleneck.

### Making it async

#### Executors and ExecutorServices

Submit tasks to the thread pools.

Gives a callback when it is done.

`Future`s hold the results of a computation. (Though, Future's in Java don't
support callbacks!).

`Promise`s are a promise to, in the future, provide results of a computation.

Guava (Google's Java lib) has `ListenableFuture` which allows real callback.

#### [Apollo](https://github.com/spotify/apollo)

An async framework from Spotify, which is open source.

Another one (that does soemthing different) is
[Netty](https://github.com/netty/netty).

### Async isn't real

When you go all the way down to OS level, everything is synchronous. There is a
research project to create an async OS going on, though!

## Limiting concurrency

* Thread pools are much like a queue.
* Always limit thread pools
    * Approx same as amount of cores, to avoid context switching and cache
      swapping.
* Prefer dropping tasks if possible
    * Unless you are a bank, where everything has fallbacks.
    * Better to tell the user that something went wrong rather than killing you
      backend with requests.
* Provide proper back pressure
    * Bounded queues in every instance (small bounds). If there is a
      bottleneck, then its request queue will fill up. Then its clients queue
      to that will fill up, and so forth until the client can't access
      anything, at which time they get an error message.

Be careful with unbounded queues! If the producer is faster than the consumer
hte queue **will** fill up.

## Further reading

* `java.util.concurrent`: Read the source code. The guy who implemented (Doug Lea) most of the classes (that do ridicolously compilcated stuff) writes great comments that lets you understand things well.
* Anything else by Doug Lea
    * Including source code.
