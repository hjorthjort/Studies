import Test.QuickCheck

evens :: Gen Int
evens = do
    n <- arbitrary
    return $ n * 2

nats :: Gen Int
nats = do
    n <- arbitrary
    return $ abs n

prop :: (Int -> Int) -> Gen Int
prop fun = do
    n <- arbitrary
    return $ fun n
