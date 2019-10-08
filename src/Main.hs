module Main where

import System.Environment
import System.Exit
import System.IO

import Language.Pail (runPail)


main = do
    args <- getArgs
    case args of
        [fileName] -> do
            c <- readFile fileName
            putStrLn $ runPail c
            return ()
        _ -> do
            abortWith "Usage: pail <filename.pail>"

abortWith msg = do
    hPutStrLn stderr msg
    exitWith (ExitFailure 1)
