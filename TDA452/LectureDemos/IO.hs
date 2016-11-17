module IO where

-- Building complex instructions from simple ones.

copyFile :: FilePath -> FilePath -> IO ()
copyFile fromFile toFile =
    do 
        c <- readFile fromFile
        writeFile toFile c

-- find longest Word in file
-- /Users/hjort/Studying/ITS023/hjort_rikard_hemtenta.tex
longest :: IO String
longest = do
        wlist <- readFile "/usr/share/dict/words"
        return (long wlist)

    where 
        long :: String -> String
        long = snd . maximum . map (\w -> (length w, w)) . words

doTwice :: IO a -> IO (a,a)
doTwice i = do
    a1 <- i
    a2 <- i
    return (a1, a2)

dont :: IO a -> IO ()
dont _ = do return ()

-- sequence
sequence_' :: [IO a] -> IO ()
sequence_' xs = foldr (>>) (return ()) xs

sequence' :: [IO a] -> IO [a]
sequence' [] = return []
sequence' (x:xs) = do
    rHead <- x
    rTail <- sequence' xs
    return $ rHead:rTail

-- syntax for IO evaluation:
-- var <- expr
-- var :: a expr :: IO a
--
cat :: [FilePath] -> FilePath -> IO ()
cat [] _ = do return ()
cat (x:xs) newFile = do
    content <- readFile x
    appendFile newFile content
    cat xs newFile

cat' xs newFile = foldl appendToNew (return ()) xs
    where 
        appendToNew _ file = do
            content <- readFile file
            putStrLn content
            appendFile newFile content
