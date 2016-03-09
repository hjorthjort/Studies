<meta charset='utf8'>
<link href="/Users/hjort/.markdown.css" rel="stylesheet"></link>

The first part of the exam is focused on theory

The second part is focused on probling solving problems

No formal separation between the parts – all points are created equal.

Generally
---------

There is not much focus on Java syntax or Java specific questions (like "how does data type X implement hashCode?")

The exception is stuff that is very important, like Generics and Comaparable/Comparator

First part
----------

Is more about concrete implementations than previous years. We won't write answers in pseudo-code, but instead in Java

Second part
-----------

Less focus on this than previous years.

Remember to comment and write legible code.

Things that are not part of *this* year's exam
----------------------------------------------

* 2-3-trees
* Splay tree implementation
* AVL tree implementation

Things to prepare for:
----------------------

**For all algorithms: should be able to describe, pseudocode, analyze and fully implement in Java**

**(EXCPETIONS TO THIS: Splay and AVL trees, since these are pretty big and technical we don't have to be able to implement them during an exam)**

* Abstract data types
    * focus on doing it object oriented
    * generics
    * Comparable/Comarator
* recursion
    * functions
    * data types (recursive data types – trees, specifically)
* complexity analysis
    * the definition
    * rules for manipulation (removal of constants, addition)
    * analysis of programs (both iterative and recursive implementations)
        * Does not require deep knowledge, since we have not went very deep in this course
    * time and space complexity
    * arithmetic sum is good to know
    * no focus on amortized complexity
* lists
    * array/array list
    * linked list, single & double
* Hash tables
    * hash codes – no focus on writing good ones, just understanding their purpose
    * hashing functions
    * collissions
    * open addressing
        * linear probing
        * should also know there are alternative probings
            * quadratic probing
    * closed addressing (aka chaining)
    * rehashing
* trees
    * terminology
        * height
        * depth
        * path
        * etc.
    * pre/in/post order traversal
    * rotations
    * binary search trees
    * balanced trees
        * AVL (retracing is the important idea) (we don't need to be able to implement, since that is too big)
        * Partially ordered, left balanced trees
            * heap (array based)
            * priority queue
    * Splay trees (splaying is the important concept)
* graphs
    * terminology
        * directed/undirected
        * weighted
        * cycle
        * DAG
        * etc.
    * representation
        * adjecency list (efterföljarlista)
        * adjecency matrix (efterföljarmatris)
    * DFS & BFS
    * Spanning trees (and minimum spanning trees)
    * Algorithms (only ONE implementation needed, doesn't have to be the books or from the lectures)
        * Prim
        * Kruskal
        * Dijkstra
* sorting (comlexity, stability, implementation of the following)
    * selection
    * bubble
    * insertion
    * merge
    * quick
    * heap
