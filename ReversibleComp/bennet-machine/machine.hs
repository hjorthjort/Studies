import Data.List
--import Control.Monad

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
  take 2 ones ++ '$':take 3 ones

-- Convert to reversible.

quadruples = concat $ map quintToQuad $ zip [1..] myRules
  where
      quintToQuad (ruleNum, (s, symIn, symOut, shift, s')) =
        let len = length myRules in
        if ruleNum < len then
          [
            ((Compute s, (Sym symIn, Ignore, Sym Blank)), ((W symOut, S R, W Blank), Compute' ruleNum)),
            ((Compute' ruleNum, (Ignore, Sym Blank, Ignore)), ((shift, W (C (head $ show ruleNum)), S Z), Compute s')) -- Hack: Assume less than 10 rules.
        ]
        else
          [
            ((Compute s, (Sym Blank, Ignore, Sym Blank)), ((W Blank, S R, W Blank), Compute' len)),
            ((Compute' len, (Ignore, Sym Blank, Ignore)), ((S Z, W N, S Z), Compute s'))
          ]

lastState = maximum $ map (\s -> case s of {Compute i -> i; Compute' _ -> -1}) $ map (\((_, _), (_, state)) -> state) quadruples

numRules = length quadruples `div` 2

copyStates = [
  ((Compute lastState, (Sym Blank, Sym N, Sym Blank)), ((W Blank, W N, W Blank), Copy' 1)),
  ((Copy' 1, (Ignore, Ignore, Ignore)), ((S R, S Z, S R), Copy 1)),
  ((Copy' 2, (Ignore, Ignore, Ignore)), ((S L, S Z, S L), Copy 2))
  ]
  ++
  symbolCopyStates
  ++
  [
    ((Copy 1, (Sym Blank, Sym N, Sym Blank)), ((W Blank, W N, W Blank), Copy' 2)),
    ((Copy 2, (Sym Blank, Sym N, Sym Blank)), ((W Blank, W N, W Blank), Retrace lastState))
  ]
  where
    copyStateFor character =
      ((Copy  1, (Sym (C character), Sym N , Sym Blank)), ((W (C character), W N, W (C character)), Copy' 1 ))

    copyAuxStateFor character =
      ((Copy  2, (Sym (C character), Sym N , Sym (C character))), ((W (C character), W N, W (C character)), Copy' 2 ))
    symbolCopyStates = (map copyStateFor $ nub input) ++ (map copyAuxStateFor $ nub input)


retraceSteps = [
  ((Retrace lastState, (Ignore, Sym N, Ignore)), ((S Z, W Blank, S Z), Retrace' numRules)),
  ((Retrace' numRules, (Sym Blank, Ignore, Sym Blank)), ((W Blank, S L, W Blank), Retrace (lastState - 1)))
               ]
  ++
  concat (map retrace (zip [1..] myRules))
  ++
  [
  ((Retrace 2, (Ignore, Sym N, Ignore)), ((S L, W Blank, S Z), Retrace' 1)),
  ((Retrace' 1, (Sym Blank, Ignore, Sym Blank)), ((W Blank, S L, W Blank), Retrace' 1))
  ]

retrace ((ruleNum), (s, symIn, symOut, shift, s')) = [
  ((Retrace s', (Ignore, Sym (C (head $ show ruleNum)), Ignore)), ((invertShift shift, W Blank, S Z), Retrace' ruleNum)), -- Again, hack, assume less than 10 original rules.
  ((Retrace' ruleNum, (Sym symOut, Ignore, Sym Blank)), ((W symIn, S L, W Blank), Retrace s))
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
type Rules = [((AutomatonState, (TapeState, TapeState, TapeState)), ((Action, Action, Action), AutomatonState))]
data TapeState = Sym Symbol | Ignore

instance Eq TapeState where
  (==) Ignore _ = True
  (==) _ Ignore = True
  (==) (Sym s1) (Sym s2) = s1 == s2

-- Automaton.
data AutomatonState = Compute Int | Compute' Int | Copy Int | Copy' Int | Retrace Int | Retrace' Int deriving (Ord, Eq)

-- Tapes.
data Symbol = C Char | Blank | N deriving (Ord, Eq) -- Alphabet.
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
  case lookup input rules of
    Nothing -> Left (concat ["Rule could not be found: ", show input])
    Just result -> Right result

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

instance Show ThreeTuringMachine where
  show TTM {machineState = (MS {automatonState = as, tapes = ts}) } = concat [show as, ", ", show ts]

instance Show AutomatonState where
  show (Compute i)     = concat ["A", "_", show i]
  show (Compute' i)    = concat ["A", "_", show i, "'"]
  show (Copy i)        = concat ["B", "_", show i, ""]
  show (Copy' i)       = concat ["B", "_", show i, "'"]
  show (Retrace i)     = concat ["C", "_", show i]
  show (Retrace' i)    = concat ["C", "_", show i, "'"]

instance Show Tapes where
  show (Tapes {standard = s, history = h, output = o}) = concat ["[", commaSeparatedTapes, "]"]
    where
      commaSeparatedTapes = concatIntersperseMap ", " show [s, h, o]

instance Show Tape where
  show tape = let Tape ps ns = printableTape tape in
    concatMap (concatMap show) [reverse ps, [C '>'], ns]

-- Removes blanks.
printableTape :: Tape -> Tape
printableTape (Tape ps ns) = Tape (nonBlank ps) (nonBlank ns)
  where
    nonBlank xs = head xs : (takeWhile (Blank /=) $ tail xs)

instance Show TapeState where
  show (Sym s) = show s
  show Ignore = "/"

instance Show Symbol where
  show (C c) = ' ':c:""
  show N = " N"
  show Blank = " b"

instance Show Action where
  show (W sym) = "Write " ++ show sym
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
