{-# LANGUAGE FlexibleInstances, UndecidableInstances #-}
module Monads (Monad') where

import Control.Monad (join)
import Data.Monoid

-- join :: f (f a) -> f a

class (Functor f, Applicative f) => Monad' f where
  join' :: f (f a) -> f a
  return' :: a -> f a

instance (Functor m, Applicative m, Monad m) => Monad' m where
  join' m = m >>= id
  return' = return

-- instance (Applicative m, Monad' m) => Monad (m) where
--   ma >>= f = join' $ fmap f ma
--   return = return'

data Foo a = List [a] deriving Show

instance Functor Foo where
  fmap f (List xs) = List (fmap f xs)

instance Applicative Foo where
  pure a = List [a]
  List fs <*> List xs = List (fs <*> xs)

instance Monad' Foo where
  join' (List []) = List []
  join' (List (List xs:_)) = List xs
  return' = pure
