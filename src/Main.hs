module Main where

import System.Environment
import Pail

main = do
    [fileName] <- getArgs
    c <- readFile fileName
    putStrLn $ runPail c
