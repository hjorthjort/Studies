import Test.QuickCheck

-- Currency converter
exchangeRate = 9.53

toEUR sek = sek / {- inline comment -} exchangeRate
toSEK eur = eur * exchangeRate

prop_exchange sek = sek / exchangeRate
x ~== y = abs (x-y) < 1e-10

power n 0 = 1
power n k = n * power n (k-1)

prop_power n k = k >= 0 ==> power n k == n^k

lc :: [Integer]
lc = [ x * y | x<-[1..20], y<-[-10..10], even x, odd y ]

pythag n = [ (x,y,z) | x <-[1..n], y<-[1..n], z<-[1..n], x <= y, x^2 + y^2 == z^2 ]
