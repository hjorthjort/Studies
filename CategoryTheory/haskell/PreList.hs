module PreList where

import Data.Bifunctor
import Test.QuickCheck

data PreList a b = Nil | Cons a b deriving (Show, Eq)
newtype List' a = PreList (List' a)

instance (Arbitrary a, Arbitrary b) => Arbitrary (PreList a b) where
  arbitrary = do
    x <- arbitrary
    y <- arbitrary
    elements [Nil, Cons x y]

instance Bifunctor PreList where
  first _ Nil = Nil
  first f (Cons x y) = Cons (f x) y
  second _ Nil = Nil
  second g (Cons x y) = Cons x (g y)


propBifunctor :: (PreList Integer String, Fun Integer Bool, Fun String [Integer]) -> Bool
propBifunctor (pl, f1, f2) =
  let f1' = applyFun f1
      f2' = applyFun f2
   in (first f1' pl == bimap f1' id pl) && (second f2' pl == bimap id f2' pl)

