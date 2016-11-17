import Data.List
import System.Random

wordFile = "/usr/share/dict/words"
guessLimit word = 2 * length word

main :: IO ()
main = do
    word <- randomWord
    -- For debugging, print the word.
    putStrLn word
    gameLoop word []

gameLoop :: String -> [Char] -> IO ()
gameLoop word guesses | guessesLeft word guesses <= 0 = putStrLn "Out of guesses"
gameLoop word guesses 
  | correct word guesses = putStrLn "Correct!"
  | otherwise = do
      putStrLn "Guess again"
      putStrLn $ ("Guesses left: " ++) $ show $ guessesLeft word guesses
      putStrLn $ status word guesses
      putStrLn $ "Failed: " ++ (guesses \\ word)
      read <- getLine
      let readFiltered = read \\ guesses
      gameLoop word $ guesses ++ readFiltered

correct :: String -> [Char] -> Bool
correct word chars = word \\ chars == ""

status :: String -> [Char] -> String
status word guesses = map (\c -> if c `elem` guesses then c else '_') word

randomWord :: IO String
randomWord = do
    content <- readFile wordFile
    let wordList = words content
    word <- pickRandom wordList
    return word

pickRandom :: [a] -> IO a
pickRandom xs = do
    rand <- newStdGen
    let (randInt, _) = randomR (0, length xs - 1) rand
    return $ xs !! randInt

guessesLeft :: String -> [Char] -> Int
guessesLeft word guesses = 12 - length (guesses \\ word)
