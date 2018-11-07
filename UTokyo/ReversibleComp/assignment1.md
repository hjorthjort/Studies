Assignment 1
============

1 and 2 are defined in Haskell.

**1. Given inverse intepreter `invint`, construct a program inverter.**
```haskell
invint :: (Program, Output) -> Input
inverter = \prog -> \out -> invint (prog, out)
```
**2. Given program inverter `inverter`, construct an inverse intepreter.**
```haskell
inverter :: Program -> Output -> Input
invint = \(prog, out) -> (inverter p) out
```

**Note on task 1 and 2:**

If we uncurry the `invint` function, so that `invint` doesn't take a tuple as
input, but rather (equvalently) takes a program and returns a function that
takes an output and returns the input, then `invint = inverter`.

```haskell
invint :: Program -> Output -> Input
inverter prog = invint prog
-- ... or equivalently:
inverter = invint

invint prog out = (inverter prog) out
-- ... or equivalently:
invint = inverter
```


**3. Run the program `fib` forward (`CALL main_fwd`) by hand. Trace the store `(n, x1, x2)` after each statement.**

```
(0, 0, 0) -- n x1 x2

(4, 0, 0) -- n += 4
(4, 0, 0) -- if n=0
(3, 0, 0) -- else n -= 1
(3, 0, 0) -- if n=0
(2, 0, 0) -- else n -= 1
(2, 0, 0) -- if n=0
(1, 0, 0) -- else n -= 1
(1, 0, 0) -- if n=0
(0, 0, 0) -- else n -= 1
(0, 0, 0) -- if n=0
(0, 1, 0) -- x2 += 1
(0, 1, 1) -- x2 += 1
# Recurse up 4 levels.
(0, 2, 1) -- x1 += x2
(0, 1, 2) -- x1 <=> x2
(0, 3, 2) -- x1 += x2
(0, 2, 3) -- x1 <=> x2
(0, 5, 3) -- x1 += x2
(0, 3, 5) -- x1 <=> x2
(0, 8, 5) -- x1 += x2
(0, 5, 8) -- x1 <=> x2
# Done
```

**4. Run the program `fib` backward (`CALL main_bwd`) by hand. Trace the store `(n, x1, x2)` after each statement.**

```
(0, 0, 0) -- n x1 x2

(0, 5, 8) -- fi x1=x2
(0, 8, 5) -- x1 <=> x2
(0, 3, 5) -- x1 += x2
# uncall fib
(0, 5, 3) -- x1 <=> x2
(0, 2, 3) -- x1 += x2
# uncall fib
(0, 3, 2) -- x1 <=> x2
(0, 1, 2) -- x1 += x2
# uncall fib
(0, 2, 1) -- x1 <=> x2
(0, 1, 1) -- x1 += x2
# uncall fib
(0, 1, 1) -- fi x1=x2
(0, 1, 0) -- x2 += 1
(0, 0, 0) -- x2 += 1
# Recurse up 4 levels.
(1, 0, 0) -- else n -= 1
(2, 0, 0) -- else n -= 1
(3, 0, 0) -- else n -= 1
(4, 0, 0) -- else n -= 1
 ```

** 5. Describe informally how you interpreted each statement `+=`, `-=`, `<=>`, `if`, `call` in Janus in both directions.**

|    | forward  | backward |
|----|----------|----------|
|+=  | add      | subtract |
|-=  | subtract | add      |
|<=> | swap     | swap     |
|if  | check if | check fi |
|call| call     | uncall   |

* `+=`, `-=`: simple addidion and subtraction. They are each other's inverses,
  so their roles are swapped depending on direction.
* `<=>`: behaves identically in both directions, since a swap is its own inverse.
* `if`: going forward, we check the `if` condition, and branch to the
  `then`-branch if `true` and `else`-branch if `false`. Going backwards, `fi` is
  checked, and branching happens in the same way (but the block is read in reverse.)
* `call`: calls a function by moving the function pointer to that procedure, and
  pushing the current position to a return stack (so that the recursion can
  return). In the backwards direction, the function is `uncall`ed in the same manner.
  
  

