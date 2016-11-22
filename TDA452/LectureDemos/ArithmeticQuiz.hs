module ArithmeticQuiz
    where
-- | Arithmetic Quiz
-- An exercise with recursive data types
-- Functional Programming course 2016.
-- Thomas Hallgren

import Control.Monad(forever)
import Data.Map as M (Map, fromList, lookup)
import Test.QuickCheck

main = do putStrLn "Welcome to the Arithmetic Quiz!"
          forever quiz

quiz =
    do e <- generate $ rExpr 3
       putStr ("\n"++showExpr e++" = ")
       answer <- getLine
       let correct = show (eval [] e)
       putStrLn (if answer == correct
                 then "Correct!"
                 else "Wrong! The correct answer is: "++correct)


-- | A representation of simple arithmetic expressions
data Expr
    = Num Integer
      | Add Expr Expr
      | Mul Expr Expr
      | Var String

-- (1+2) * 4
expr1 = Mul (Add (Num 1) (Num 2)) (Num 4)
-- 1 + 1 * 4
expr2 = Add (Num 1) (Mul (Var "y") (Num 4))
expr3 = (Var "y") `Add` ((Num 4) `Mul` (Var "x"))

vars :: Expr -> [String]
vars (Num n)    = []
vars (Var s)    = [s]
vars (Add e1 e2) = vars e1 ++ vars e2
vars (Mul e1 e2) = vars e1 ++ vars e2

type Table = Map String Integer

newtype Env = Env Table deriving Show

instance Arbitrary Env where
    arbitrary = do
        l <- infiniteList
        return $ Env $ fromList $ zip (map (:"") ['a'..'z']) l

simplify :: Expr -> Env -> Expr
simplify = undefined

-- | Computing the value of an expression
eval :: [(String, Integer)] -> Expr -> Integer
eval l e = eval' e where
    eval' (Num x) = x
    eval' (Add x y) = eval' x + eval' y
    eval' (Mul x y) = eval' x * eval' y
    eval' (Var x) = maybe (error $ "No value for " ++ x) id 
        $ let t = M.fromList l in M.lookup x t

derive :: String -> Expr -> Expr
derive x (Add e1 e2) = derive x e1 `add` derive x e2
derive x (Mul e1 e2) = (derive x e1 `mul` e2) `Add` (e1 `mul` derive x e2)
derive x (Var x') | x == x' = Num 1
derive _ _ = Num 0

add :: Expr -> Expr -> Expr
add (Num n) (Num m) = Num $ n + m
add (Num 0) e       = e
add e (Num 0)       = e
add e1 e2           = e1 `Add` e2

mul :: Expr -> Expr -> Expr
mul (Num n) (Num m) = Num $ n * m
mul (Num 0) e       = Num 0
mul e (Num 0)       = Num 0
mul (Num 1) e       = e
mul e (Num 1)       = e
mul e1 e2           = e1 `Mul` e2

-- | Showing expressions
showExpr :: Expr -> String
showExpr (Num x) = show x
showExpr (Var x) = x
showExpr (Add x y) = showExpr x ++ " + " ++ showExpr y
showExpr (Mul x y) = showFactor x ++ " * " ++ showFactor y
    where
        showFactor (Add e1 e2) = "(" ++ showExpr (Add e1 e2) ++ ")"
        showFactor e = showExpr e

instance Show Expr where show = showExpr
instance Eq Expr where
    e1 == e2 = eval [] e1 == eval [] e2

-- * Generating arbitrary expressions

range = 4
level = fromInteger range

rExpr :: Int -> Gen Expr
rExpr s = frequency [(1, rNum), (s,rBin s)]
    where
        rNum = fmap Num arbitrary
        rVar = elements $ map Var $ map (:"") ['a'..'z']
        rBin s = do
            let s' = s `div` 2
            op <- elements [Mul, Add]
            e1 <- rExpr s'
            e2 <- rExpr s'
            return $ op e1 e2

instance Arbitrary Expr where
    arbitrary = sized rExpr
