main = do
     putStrLn $ show $ implementsOr mySolution

-- A Toffoli gate.
toffoli :: (Integer, Integer, Integer) -> (Integer, Integer, Integer)
toffoli (a, b, c) = if a == 1 && b == 1 then (1, 1, 1 - c) else (a, b, c)

setA a = \b c -> toffoli (a, b, c)
setB b = \a c -> toffoli (a, b, c)
setC c = \a b -> toffoli (a, b, c)

andGate = setC 0
xorGate = setA 1

-- Truth table.
-- Check that a function implements OR.
implements :: [[Integer]] -> (Integer -> Integer -> Integer) -> Bool
implements table f = and $ map (\row -> f (row !! 0) (row !! 1) == (row !! 2)) table

orTable = [[0, 0, 0], [0, 1, 1], [1, 0, 1], [1, 1, 1]]

implementsOr = implements orTable


-- Known working implementation
mySolution a b =
  case (andGate a b) of
    (a, b, andAB) -> case xorGate a b of
        (1, a, xorAB) -> case xorGate xorAB andAB of
            (1, xorAB, orAB) -> orAB
