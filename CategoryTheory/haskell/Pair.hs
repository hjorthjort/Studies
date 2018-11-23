{-# LANGUAGE DeriveFunctor #-}
module Pair where

import Data.Bifunctor

data Pair a b = Pair a b deriving Show

instance Bifunctor Pair where
  -- Implement a simple version of these functions, for the sake of using equational reasoning.
  bimap f g (Pair x y) = Pair (f x) (g y)
  first f (Pair x y) = Pair (f x) y
  second g (Pair x y) = Pair x (g y)


-- A cleaner implementation.

data Pair' a b = Pair' a b deriving (Show, Functor)

instance Bifunctor Pair' where
  first f (Pair' x y) = Pair' (f x) y
  second = fmap
