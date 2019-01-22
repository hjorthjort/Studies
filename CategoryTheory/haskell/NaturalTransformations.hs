module NaturalTransformations where

import Test.QuickCheck
import qualified Data.Map as M

listToMaybe :: [a] -> Maybe a
listToMaybe [] = Nothing
listToMaybe (x:xs) = Just x

maybeToList :: Maybe a -> [a]
maybeToList Nothing = []
maybeToList (Just x) = [x]

-- Tests.

prop_listMaybeIsomorphic :: (Num a, Eq a, Eq b) => Maybe a -> Fun a (M.Map a b) -> Bool
prop_listMaybeIsomorphic x f' = let f = applyFun f'
                                   in maybeToList (f <$> x) == (f <$> maybeToList x)
prop_maybeListIsomorphic :: (Num a, Eq a, Eq b) => [a] -> Fun a (M.Map a b) -> Bool
prop_maybeListIsomorphic x f' = let f = applyFun f'
                                   in listToMaybe (f <$> x) == (f <$> listToMaybe x)
