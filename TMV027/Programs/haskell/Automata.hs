module Automata 
( newAutomaton )
where

data Atom =  Epsilon | Empty | Char deriving (Show)

data State = State [Char] deriving (Show)

Show (State -> Atom -> State) = "delta"

data Automaton = Automaton {
                              states :: [State]
                            , alphabet :: [Char]
                            , delta :: State -> Atom -> State
                            , starting :: State
                            , final :: State -> Bool
                            } deriving (Show)

newAutomaton :: Automaton
newAutomaton = Automaton [ State "q0", State "q1"] "01" delta1 (State "q0") final1

delta1 :: State -> Atom -> State
delta1 _ _ = State "q0"

final1 :: State -> Bool
final1 _ = True
