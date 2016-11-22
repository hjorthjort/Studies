module Parser
    where

import ArithmeticQuiz
import Data.Char

u = undefined

expr :: Parser Expr
parse = expr . filter (not . isSpace)

-- BNF-style grammar
-- <expression> ::= <term> | <term> "+" <expression>
expr :: Parser Expr
expr s = case term s of
           Just (t, '+':s') -> case expr s' of
                                 Just (e, s'')  -> Just (t `Add` e, s'')
                                 Nothing        -> Just (t, '+':s')
           r                -> r

-- <term>       ::= <factor> | <factor> "*" <term>
term :: Parser Expr
term s = case factor s of
           Just (n, '*':s') -> case term s' of
                                 Just (n', s'') -> Just (n `Mul` n', s'')
                                 Nothing        -> Just (n, '*':s')
           r                -> r

-- <factor>     ::= "(" <expression> ")" | <number>
factor :: Parser Expr
factor ('(':s) = case expr s of
                   Just (e, ')':s') -> Just (e, s')
                   _                -> Nothing
factor s = num s

-- warm up: parse n1+n2+...+nk for k>=1
expr1' s = case num s of
           Just (n, '+':s')    -> case expr1' s' of
                                     Just (n', s'') -> Just (n `Add` n', s'')
                                     Nothing        -> Just (n, '+':s')
           r                   -> r

type Parser a = String -> Maybe (a, String)

num :: Parser Expr
num s = case reads s of
          (i,s'):_  -> Just (Num i, s')
          _         -> Nothing
