# Ast Sysntaz

Wrap all expressions in a simple constructor with location annotation?

Or add loaction to every constructor?

Location: 4 nums. begin col, begin row, end col, end row

Decision: An additional recursive constructor with location annotation

# Vocab

* Case-splitting
* env-refactor
* accumulator (for the environment). Is it a fold acculumulator?
* AST vs Concrete ST
* bootstrap

# QA

* Why not have a constructor, lexp, that wraps an exp? Then you can not have
  lexp lexp lexp ... exp, but only always lexp exp.
* Why do we need the location from source? weren't we going to start in BVL?
