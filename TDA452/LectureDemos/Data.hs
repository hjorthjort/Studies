-- Deck
data Suit = Spades | Hearts | Diamonds | Clubs
    deriving (Show, Eq, Ord, Enum)

data Color = Red | Black
             deriving Show

data Rank = Numeric Int | Face FaceRank
    deriving (Show, Ord, Eq)

data FaceRank = Jack | Queen | King | Ace
    deriving (Show, Enum, Ord, Eq)

data Card = Card {rank::Rank, suit::Suit}
    deriving (Show, Eq, Ord)

color :: Suit -> Color
color Spades    = Black
color Clubs     = Black
color _         = Red

cardBeats :: Card -> Card -> Bool

cardBeats c1 c2 = rank c1 > rank c2 && suit c1 == suit c2

deck = [ (Card r s) | 
    r <- 
        [ Numeric x | x <- [2..10] ] ++ 
            [Face f | f <- [Jack .. Ace]], 
    s <- [Spades .. Clubs]]



ex_card1 = Card (Face Jack) Hearts
ex_card2 = Card (Numeric 5) Hearts
ex_card3 = Card (Face Ace) Hearts
ex_card4 = Card (Numeric 2) Clubs


data Hand = Empty | Add Card Hand
    deriving (Show, Eq)

ex_hand1 = Add ex_card1 Empty
ex_hand2 = Add ex_card2 ex_hand1

handBeats :: Hand -> Card -> Bool
Empty `handBeats` _   = False
(Add c hand) `handBeats`  other = c `cardBeats` other || hand `handBeats` other

betterCards :: Hand -> Card -> Hand
betterCards Empty _   = Empty
betterCards (Add c hand) other    
  | c `cardBeats` other  = Add c (betterCards hand other)
  | otherwise = betterCards hand other

sameSuit :: Hand -> Suit -> Hand
sameSuit Empty _   = Empty
sameSuit (Add c hand) s    
  | suit c == s  = Add c (sameSuit hand s)
  | otherwise =  sameSuit hand s

lowestCard :: Hand -> Card
lowestCard Empty = error "Empty hand"
lowestCard (Add c Empty) = c
lowestCard (Add c h)    | rank c <= rank low = c
                        | otherwise = low
    where
        low = lowestCard h

chooseCard  :: Card -> Hand -> Card
chooseCard card hand    
  | hand `handBeats` card = lowestCard (betterCards hand card)
  | sameSuit hand (suit card) /= Empty = lowestCard (sameSuit hand (suit card))
  | otherwise = lowestCard hand

