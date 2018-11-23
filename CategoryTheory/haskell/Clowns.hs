{-# LANGUAGE DeriveFunctor #-}

-- Due to Bartosz, Challenge 8:4 and http://strictlypositive.org/CJ.pdf
module Clowns where

import Data.Bifunctor
import Test.QuickCheck

data K2 c a b = K2 c deriving (Show, Eq)

instance Bifunctor (K2 c) where
  bimap _ _ (K2 x) = (K2 x)

data Fst a b = Fst a deriving (Show, Eq)

instance Bifunctor Fst where
  bimap f _ (Fst x) = Fst (f x)

data Snd a b = Snd b deriving (Show, Eq, Functor)

instance Bifunctor Snd where
  bimap _ g (Snd x) = fmap g (Snd x)

-- Testing.

makeArb constructor = arbitrary >>= return . constructor

instance Arbitrary c => Arbitrary (K2 c a b) where
  arbitrary = makeArb K2

instance Arbitrary b => Arbitrary (Snd a b) where
  arbitrary = makeArb Snd

instance Arbitrary a => Arbitrary (Fst a b) where
  arbitrary = makeArb Fst

uncurry3 :: (a -> b -> c -> d) -> (a, b, c) -> d
uncurry3 f = \(x, y, z) -> f x y z

propBifunctor :: (Bifunctor f, Eq (f c d)) => f a b -> Fun a c -> Fun b d -> Bool
propBifunctor k f1 f2 = bimap (applyFun f1) (applyFun f2) k == (second (applyFun f2) . first (applyFun f1)) k

propBifunctorK2 :: (Eq c, Eq d) => (K2 Int a b, Fun a c, Fun b d) -> Bool
propBifunctorK2 = uncurry3 propBifunctor

propBifunctorFst :: (Eq c, Eq d) => (Fst a b, Fun a c, Fun b d) -> Bool
propBifunctorFst = uncurry3 propBifunctor

propBifunctorSnd :: (Eq c, Eq d) => (Snd a b, Fun a c, Fun b d) -> Bool
propBifunctorSnd = uncurry3 propBifunctor

