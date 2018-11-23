module ADTBasics where

-- Addititve identity.
data Const a b = Const a deriving (Show, Eq)

instance Functor (Const a) where
  fmap _ (Const x) = Const x

-- Multiplicative identity.
newtype Identity a = Identity a deriving (Show, Eq)

instance Functor Identity where
  fmap f (Identity x) = Identity (f x)


type Maybe' a = Either (Const () a) (Identity a)

maybeToMaybe' :: Maybe a -> Maybe' a
maybeToMaybe' x = case x of
  Nothing -> Left $ Const ()
  Just y -> Right $ Identity y


maybe'ToMaybe :: Maybe' a -> Maybe a
maybe'ToMaybe x = case x of
  Left _ -> Nothing
  Right (Identity y) -> Just y

-- Tests
propIsomorphicMaybe m = m == (maybe'ToMaybe . maybeToMaybe') m

