{-# LANGUAGE DeriveAnyClass #-}
module Kleisli where

import Prelude
import Test.QuickCheck

class Kleisli m where
  (>=>) :: (a -> m b) -> (b -> m c) -> a -> m c
  kreturn :: a -> m a
  kmap :: (a -> b) -> m a -> m b
  kmap f = id >=>  \x -> kreturn (f x)


data Writer a = W a String deriving (Show, Eq)

instance Arbitrary a => Arbitrary (Writer a) where
  arbitrary = arbitrary >>= \x -> (arbitrary >>= return . W x)

instance Kleisli Writer where
  m1 >=> m2 = \x ->
                let (W y s)  = m1 x
                    (W z s') = m2 y
                 in W z (s ++ s')
  kreturn x = W x ""

instance Functor Writer where
  fmap f (W x s) = W (f x) s

-- Tests

propKmap :: Eq b => ((Fun a b), Writer a) -> Bool
propKmap (fun, m) = let f = applyFun fun in
  (kmap f m) == ((id >=> \x -> kreturn (f x)) m)
