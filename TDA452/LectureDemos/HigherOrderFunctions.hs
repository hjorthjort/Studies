-- | Higher Order Functions
-- Examples to introduce and illustrate the power of higher order functions
-- Functional Programming course 2016.
-- Thomas Hallgren

{-
This is just a skeleton, the definitions will be filled in
during the lecture.
-}

import Prelude hiding (map,filter,sum,product,concat,
                       dropWhile,lines)
import Data.Char(isSpace)
import Data.List(map,group,sort)

makeCommSep :: Show a => [a] -> String
makeCommSep xs = init $ foldr (\a s -> show a ++ "," ++ s) "" xs

takeLine :: String -> String
takeLine = takeWhile (/='\n')

takeWord :: String -> String
takeWord = takeWhile  (not . isSpace)

testLine = "A larger example: counting words in a string\n and produce nicely formatted output,          \n written in point-free style                 \n "

takeWhile' :: (a -> Bool) -> [a] -> [a]
takeWhile' _ [] = []
takeWhile' f (x:xs) | f x = x:takeWhile' f xs
  | otherwise = []

dropWhile' :: (a -> Bool) -> [a] -> [a]
dropWhile' _ [] = []
dropWhile' f (x:xs) | f x = dropWhile' f xs
  | otherwise = x:xs

splitBy :: (a -> Bool) -> [a] -> [[a]]
splitBy _ [] = []
splitBy f xs = takeWhile' (not . f) xs:(splitBy f $ drop 1 $ dropWhile' (not . f) xs)

lines = splitBy (=='\n')
commSep = splitBy (==',')

input = "hello world hello sky"

wordCount = putStr . unlines . map (\(n, w) -> w ++ ": " ++ show n) . map (\x -> (length x, head x))
            . group . sort . words

-- * First some examples of first order functions on lists

-- sum :: Num a => [a] -> a

-- product :: Num a => [a] -> a

-- concat :: [[a]] -> [a]


-- * Factor out the differences from the common pattern


-- foldr


-- map :: (a->b) -> [a] -> [b]

-- filter :: (a->Bool) -> [a] -> [a]

-- * Can we rewrite map & filter too with foldr?

--map'

--filter'

-- * More examples

-- takeLine

-- takeWord

-- takeWhile

-- dropWhile

-- lines

-- segments


-- * A larger example: counting words in a string
-- and produce nicely formatted output,
-- written in "point-free style"

-- countWords :: String -> String
