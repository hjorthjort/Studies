import Data.List
import System.Random

wordFile = "/usr/share/dict/words"
guessLimit = 12

main :: IO ()
main = do
    word <- randomWord
    -- For debgging, print the word.
    putStrLn word
    gameLoop word []

gameLoop :: String -> [Char] -> IO ()
gameLoop _ _ = putStrLn "Out of guesses"

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

