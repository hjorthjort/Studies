#Questions

## Part 2

What is up with the statements p3 and q3? Is it supposed to be an || (or)? Otherwise this does not make any sense.

## Part 3

In the scond version of the code (the consultant's code), what are they locking? Account objects? There is no lock method on these. Should it be `store[source].l.lock()`, perhaps?
