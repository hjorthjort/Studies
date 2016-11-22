u = undefined

-- BNF-style grammar
-- <expression> ::= <term> | <term> "+" <expression>
expr s = u

-- <term>       ::= <factor> | <factor> "*" <term>
term s = u

-- <factor>     ::= "(" <expression ")" | <number>
factor = u
