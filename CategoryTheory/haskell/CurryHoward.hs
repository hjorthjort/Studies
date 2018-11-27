{-# LANGUAGE TypeOperators #-}

module CurryHoward where

newtype Void = Void Void

absurd :: Void -> a
absurd = undefined

type T = ()

type p \/ q = Either p q

type Neg p = p -> Void

-- Modus ponens.
mp :: (p -> q, p) -> q
mp (f, p) = f p

-- Modus tollens.
mt :: (p -> q) -> Neg q -> Neg p
mt p_to_q neg_q = \p -> neg_q (p_to_q p)

-- Negation of implication.
-- (p -> q) -> Void
-- _____
-- | q
-- | _____
-- | | p
-- | | q
-- | |_____
-- | p -> q
-- | Void
-- |_____
-- q -> Void
-- _____
-- | p -> Void
-- | ____
-- | | p
-- | | Void
-- | | q
-- | |___
-- | p -> q
-- | Void
-- ____
-- (p -> Void) -> Void
-- (Neg (Neg p), Neg q)
neg_imp :: Neg (p -> q) -> (Neg (Neg p), Neg q)
neg_imp not___p_to_q =
  let not_q            = \q -> not___p_to_q (\p -> q)
      not_p_to_p_to_q  = \not_p -> \p -> (absurd (not_p p))::q
      not_not_p        = \not_p -> not___p_to_q (not_p_to_p_to_q not_p)
  in (not_not_p, not_q)

imp_neg_conj :: (p -> q) -> Neg (p, Neg q)
imp_neg_conj p_to_q = \(p, not_q) ->
  (not_q . p_to_q) p

-- Disjunction.
disjunction_commutes :: p \/ q -> q \/ p
disjunction_commutes e = case e of
  Left x -> Right x
  Right x -> Left x

disjunction_associates :: p \/ (q \/ r) -> (p \/ q) \/ r
disjunction_associates e = case e of
  Left p -> Left (Left p)
  Right e' -> case e' of
    Left q -> Left (Right q)
    Right r -> Right r

-- Conjunction.
conjunction_commutes :: (p, q) -> (q, p)
conjunction_commutes (p, q) = (q, p)

conjunction_associates :: (p, (q, r)) -> ((p, q), r)
conjunction_associates (p, (q, r)) = ((p, q), r)

-- De Morgan
conj_dm :: (p, q) -> Neg (Neg p \/ Neg q)
conj_dm (p, q) = \not_p_or_not_q ->
  case not_p_or_not_q of
    Left (not_p) -> not_p p
    Right (not_q) -> not_q q

disj_dm :: p \/ q -> Neg (Neg p, Neg q)
disj_dm p_or_q = case p_or_q of
  Left p -> \(not_p, _) -> not_p p
  Right q -> \(_, not_q) -> not_q q

disj_neg_dm :: (Neg p, Neg q) -> Neg (p \/ q)
disj_neg_dm (not_p, not_q) = \not___p_or_q ->
  case not___p_or_q of
    Left p -> not_p p
    Right q -> not_q q

conj_neg_dm :: Neg p \/ Neg q -> Neg (p, q)
conj_neg_dm not_p_or_not_q = \(p, q) ->
  case not_p_or_not_q of
    Left not_p -> not_p p
    Right not_q -> not_q q

-- Misc.
impl_disjunction :: (p -> r) \/ (q -> r) -> (p, q) -> r
impl_disjunction disj (p, q) = case disj of
  Left f  -> f p
  Right f -> f q

