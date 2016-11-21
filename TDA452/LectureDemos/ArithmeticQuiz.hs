-- | Arithmetic Quiz
-- An exercise with recursive data types
-- Functional Programming course 2016.
-- Thomas Hallgren

import Control.Monad(forever)
import Test.QuickCheck

main = do putStrLn "Welcome to the Arithmetic Quiz!"
          forever quiz

quiz =
    do e <- generate rExpr
       putStr ("\n"++showExpr e++" = ")
       answer <- getLine
       let correct = show (eval e)
       putStrLn (if answer == correct
                 then "Correct!"
                 else "Wrong! The correct answer is: "++correct)


-- | A representation of simple arithmetic expressions
data Expr 
    = Num Integer
      | Add Expr Expr
      | Mul Expr Expr

-- (1+2) * 4
expr1 = Mul (Add (Num 1) (Num 2)) (Num 4)
-- 1 + 1 * 4
expr2 = Add (Num 1) (Mul (Num 1) (Num 4))

-- | Computing the value of an expression
eval :: Expr -> Integer
eval (Num x) = x
eval (Add x y) = eval x + eval y
eval (Mul x y) = eval x * eval y

-- | Showing expressions
showExpr :: Expr -> String
showExpr (Num x) = show x
showExpr (Add x y) = showExpr x ++ " + " ++ showExpr y
showExpr (Mul x y) = showFactor x ++ " * " ++ showFactor y

showFactor (Add e1 e2) = "(" ++ showExpr (Add e1 e2) ++ ")"
showFactor e = showExpr e

instance Show Expr where show = showExpr
instance Eq Expr where 
    e1 == e2 = eval e1 == eval e2

-- * Generating arbitrary expressions

rExpr :: Gen Expr
rExpr = undefined

--instance Arbitrary Expr where
--  arbitrary =
