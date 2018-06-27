import Data.List
import Text.Printf

-- My machine of choice.
myRules = [
  (1, Blank, Blank, S R, 2),
  (2, C '$', Blank, S Z, 4),
  (2, C '1', Blank, S R, 3),
  (3, C '1', C '1', S R, 3),
  (3, C '$', C '1', S L, 4),
  (4, C '1', C '1', S L, 4),
  (4, Blank, Blank, S Z, 5)
  ]

myInput = let ones = repeat '1' in
  take 2 ones ++ '$':take 1 ones

-- Convert to reversible.

data Program = Program [Quadruple]
data Quadruple = Q { s:: AutomatonState, tapeS :: (TapeState, TapeState, TapeState), actions :: (Action, Action, Action), s' :: AutomatonState } deriving Eq

quadruples = concat $ map quintToQuad $ zip [1..] myRules
  where
      quintToQuad (ruleNum, (s, symIn, symOut, shift, s')) =
          [
            Q (Compute s) (Sym symIn, Ignore, Sym Blank) (W symOut, S R, W Blank) (Compute' ruleNum),
            Q (Compute' ruleNum) (Ignore, Sym Blank, Ignore) (shift, W (numToSym ruleNum), S Z) (Compute s')
          ]

lastState = maximum $ map (\(_,_,_,_,s') -> s') myRules
numToSym num = C $ head $ show num -- Hack: Assume less than 10 rules.
numRules = length myRules
n = numToSym numRules


copyStates = [
  Q (Compute lastState) (Sym Blank, Sym n, Sym Blank) (W Blank, W n, W Blank) (Copy' 1),
  Q (Copy' 1) (Ignore, Ignore, Ignore) (S R, S Z, S R) (Copy 1),
  Q (Copy' 2) (Ignore, Ignore, Ignore) (S L, S Z, S L) (Copy 2)
  ]
  ++
  symbolCopyStates
  ++
  [
    Q (Copy 1) (Sym Blank, Sym n, Sym Blank) (W Blank, W n, W Blank) (Copy' 2),
    Q (Copy 2) (Sym Blank, Sym n, Sym Blank) (W Blank, W n, W Blank) (Retrace lastState)
  ]
  where
    copyStateFor character =
      Q (Copy  1) (Sym (C character), Sym n , Sym Blank) (W (C character), W n, W (C character)) (Copy' 1)
    copyAuxStateFor character =
      Q (Copy  2) (Sym (C character), Sym n , Sym (C character)) (W (C character), W n, W (C character)) (Copy' 2)
    symbolCopyStates = (map copyStateFor $ nub input) ++ (map copyAuxStateFor $ nub input)

retraceSteps = [
  Q (Retrace lastState) (Ignore, Sym n, Ignore) (S Z, W Blank, S Z) (Retrace' numRules),
  Q (Retrace' numRules) (Sym Blank, Ignore, Sym Blank) (W Blank, S L, W Blank) (Retrace (lastState - 1))
               ]
  ++
  (concat $ map retrace $ tail $ reverse $ zip [1..] myRules)

retrace ((ruleNum), (s, symIn, symOut, shift, s')) = [
  Q (Retrace s') (Ignore, Sym (C (head $ show ruleNum)), Ignore) (invertShift shift, W Blank, S Z) (Retrace' ruleNum), -- Again, hack, assume less than 10 original rules.
  Q (Retrace' ruleNum) (Sym symOut, Ignore, Sym Blank) (W symIn, S L, W Blank) (Retrace s)
                                        ]
  where
    invertShift (S L) = S R
    invertShift (S R) = S L
    invertShift (S Z) = S Z

input = myInput
rulesList = quadruples ++ copyStates ++ retraceSteps

a_1 = Compute 1
a_f = Retrace' 1

-- Full machine.
data ThreeTuringMachine = TTM {
  machineState :: MachineState,
  rules :: Rules,
  terminateState :: AutomatonState,
  startState :: AutomatonState } deriving Eq
data Action = W Symbol | S Shift deriving Eq
data Shift = L | Z | R deriving Eq
data MachineState = MS { automatonState :: AutomatonState, tapes:: Tapes } deriving Eq
type Rules = [Quadruple]
data TapeState = Sym Symbol | Ignore

instance Eq TapeState where
  (==) Ignore _ = True
  (==) _ Ignore = True
  (==) (Sym s1) (Sym s2) = s1 == s2

-- Automaton.
data AutomatonState = Compute Int | Compute' Int | Copy Int | Copy' Int | Retrace Int | Retrace' Int deriving (Ord, Eq)

-- Tapes.
data Symbol = C Char | Blank deriving (Ord, Eq) -- Alphabet.
data Tape = Tape Prev Next -- Two infinite stacks
type Prev = [Symbol]
type Next = [Symbol]
data Tapes = Tapes { standard :: Tape, history :: Tape, output :: Tape } deriving Eq


instance Eq Tape where
  (==) (Tape ps1 ns1) (Tape ps2 ns2) = (ps1 `eq` ps2) && (ns1 `eq` ns2)
    where
      eq (Blank:a) (Blank:b) = nonBlank a == nonBlank b
      eq a b = nonBlank a == nonBlank b
      nonBlank = takeWhile (Blank /=)

machine :: ThreeTuringMachine
machine = TTM { machineState = initial, rules = rulesList, startState = a_1, terminateState = a_f}
  where
    initial = MS {automatonState = a_1, tapes = tapesFromInput input}
    tapesFromInput inp =
      let blanks = repeat Blank in
      let empty = Tape blanks blanks in
      Tapes {standard = Tape blanks (Blank:(map C inp) ++ blanks), history = empty, output = empty}
-- Full execution.
executionTrace :: ThreeTuringMachine -> [Either String ThreeTuringMachine]
executionTrace machine =
  stepThrough (Right machine) [Right machine]
  where
    stepThrough machine (m:ms) = let next = machine >>= step in
                                   if next == m then (m:ms)
                                   else stepThrough next (next:m:ms)

step :: ThreeTuringMachine -> Either String ThreeTuringMachine
step ttm@(TTM {machineState = ms, rules = rs, terminateState = term}) =
  case ms of
    (MS {automatonState = state, tapes = ts }) ->
      if state == term
         then Right ttm -- Terminate
         else do
          (s, h, o) <- readTapes ts
          result <- ruleLookup (state, (Sym s, Sym h, Sym o)) rs
          Right $ ttm {machineState = updateAccordingToRule result ms}

ruleLookup input rules =
  case (input, rules) of
    (_, []) -> Left (concat ["Rule could not be found: ", show input])
    ((state, tape), r@(Q{s = state', tapeS = tape'}):rs) ->
      if state == state' && tape == tape' then Right (actions r, s' r)
      else ruleLookup input rs

readTapes :: Tapes -> Either String (Symbol, Symbol, Symbol)
readTapes (Tapes {standard = s, history = h, output = o}) = do
  s <- r s
  h <- r h
  o <- r o
  return (s, h, o)
    where
      r (Tape _ []) = Left "Tape is Empty" -- Does not happen with infinite tape.
      r (Tape _ (n:ns)) = Right n

main = do
  putStrLn "Quadruples"
  putStrLn $ take (length "Quadruples") (repeat '=')
  putStrLn ""
  putStrLn $ show $ Program $ rules machine
  putStrLn ""
  putStrLn "Computation"
  putStrLn $ take (length "Computation") (repeat '=')
  putStrLn ""
  putStrLn $ "| State | Standard  | History   | Output      | "
  putStrLn $ "|-------|-----------|-----------|-------------| "
  putStrLn $
    prettyTrace $ map singleTrace $ reverse $ executionTrace machine
    where
      singleTrace t = case t of
                        Left string -> string
                        Right machine -> show machine
      prettyTrace trace = concat $ intersperse "\n" trace

-- Helpers.

updateAccordingToRule :: ((Action, Action, Action), AutomatonState) -> MachineState -> MachineState
updateAccordingToRule (actions, newS) machineState = machineState {automatonState = newS, tapes = update actions (tapes machineState)}

-- Assuming infinite tapes.
update :: (Action, Action, Action) -> Tapes -> Tapes
update (a1, a2, a3) ts = ts {standard = u a1 s, history = u a2 h, output = u a3 o}
  where
    s = standard ts
    h = history  ts
    o = output   ts
    u (W sym) (Tape ps (n:ns)) = Tape ps (sym:ns)
    u (S L) (Tape (p:ps) ns) = Tape ps (p:ns)
    u (S Z) t = t
    u (S R) (Tape ps (n:ns)) = Tape (n:ps) ns

concatIntersperseMap i f xs = concat $ intersperse i $ map f xs

-- Showing.

instance Show Program where
  show (Program qs) = let header = ("| State | Tape    | Action  | State'|") in
    header ++ "\n" ++ map (\c -> if c == '|' then '|' else '-') header ++ "\n" ++ concatIntersperseMap "\n" show qs

instance Show Quadruple where
  show q = printf "| %-4s | %s | %s | %s |" (show (s q)) (show (tapeS q)) (show (actions q)) (show (s' q))

instance Show ThreeTuringMachine where
  show TTM {machineState = (MS {automatonState = as, tapes = ts}) } = printf "| %s | %s |" (show as) (show ts)

instance Show AutomatonState where
  show (Compute i)     = printf "A_%d  " i
  show (Compute' i)    = printf "A_%d' " i
  show (Copy i)        = printf "B_%d  " i
  show (Copy' i)       = printf "B_%d' " i
  show (Retrace i)     = printf "C_%d  " i
  show (Retrace' i)    = printf "C_%d' " i

instance Show Tapes where
  show (Tapes {standard = s, history = h, output = o}) = printf "%-10s| %-10s| %-10s " (show s) (show h) (show o)

instance Show Tape where
  show tape = let Tape ps ns = printableTape tape in
    printf "`%s%s%s`" (concatMap show $ reverse ps) ">" (concatMap show ns)

-- Removes blanks.
printableTape :: Tape -> Tape
printableTape (Tape ps ns) = Tape (nonBlank ps) (nonBlank ns)
  where
    nonBlank xs = head xs : (takeWhile (Blank /=) $ tail xs)

instance Show TapeState where
  show (Sym s) = show s
  show Ignore = "/"

instance Show Symbol where
  show (C c) = c:""
  show Blank = "b"

instance Show Action where
  show (W sym) = show sym
  show (S L)   = "-"
  show (S Z)   = "0"
  show (S R)   = "+"

-- Scratch

-- quadruples = [
--   -- Regular states.
--   ((Compute 1, (Sym Blank, Ignore, Sym Blank)), ((W Blank, S R, W Blank), Compute' 1)),      -- 1
--   ((Compute' 1, (Ignore, Sym Blank, Ignore)), ((S R, W (C '1'), S Z), Compute 2)),           -- 1
--   ((Compute 2, (Sym (C '$'), Ignore, Sym Blank)), ((W Blank, S R, W Blank), Compute' 2)),    -- 2
--   ((Compute' 2, (Ignore, Sym Blank, Ignore)), ((S Z, W (C '2'), S Z), Compute 4)),           -- 2
--   ((Compute 2, (Sym (C '1'), Ignore, Sym Blank)), ((W Blank, S R, W Blank), Compute' 3)),    -- 3
--   ((Compute' 3, (Ignore, Sym Blank, Ignore)), ((S R, W (C '3'), S Z), Compute 3)),           -- 3
--   ((Compute 3, (Sym (C '1'), Ignore, Sym Blank)), ((W (C '1'), S R, W Blank), Compute' 4)),  -- 4
--   ((Compute' 4, (Ignore, Sym Blank, Ignore)), ((S R, W (C '4'), S Z), Compute 3)),           -- 4
--   ((Compute 3, (Sym (C '$'), Ignore, Sym Blank)), ((W (C '1'), S R, W Blank), Compute' 5)),  -- 5
--   ((Compute' 5, (Ignore, Sym Blank, Ignore)), ((S L, W (C '5'), S Z), Compute 4)),           -- 5
--   ((Compute 4, (Sym (C '1'), Ignore, Sym Blank)), ((W (C '1'), S R, W Blank), Compute' 6)),  -- 6
--   ((Compute' 6, (Ignore, Sym Blank, Ignore)), ((S L, W (C '6'), S Z), Compute 4)),           -- 6
--   ((Compute 4, (Sym Blank, Ignore, Sym Blank)), ((W Blank, S R, W Blank), Compute' 7)),      -- 7
--   ((Compute' 7, (Ignore, Sym Blank, Ignore)), ((S Z, W N, S Z), Compute 5))                  -- 7
--   ]
