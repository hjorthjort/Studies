module Parser
    where

import ArithmeticQuiz
import Data.Char
import Data.Maybe
import Test.QuickCheck

u = undefined

parse :: String -> Expr
parse = maybe (error "Not a valid expression") id . readExpr

readExpr s = case expr (filter (not.isSpace) s) of
               Just (e, "") -> Just e
               _            -> Nothing

chain :: Parser Expr -> Char -> (Expr ->  Expr -> Expr) -> Parser Expr
chain p c f s =
    case p s of
      Just (e, c':s') | c == c' -> case chain p c f s' of
                                     Just (e', s'') -> Just (e `f` e', s'')
                                     Nothing        -> Just (e, c:s')
      r                         -> r

-- BNF-style grammar
-- <expression> ::= <term> | <term> "+" <expression>
expr :: Parser Expr
expr = chain term '+' Add

-- <term>       ::= <factor> | <factor> "*" <term>
term :: Parser Expr
term = chain factor '*' Mul

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


-- Testing

prop_readExpr e = let s = show e in
                      readExpr s == Just e
