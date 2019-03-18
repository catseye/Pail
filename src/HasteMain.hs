module Main where

import Haste
import Haste.DOM
import Haste.Events

import Pail

main = withElems ["prog", "result", "run-button"] driver

driver [progElem, resultElem, runButtonElem] = do
    onEvent runButtonElem Click $ \_ -> execute
    where
        execute = do
            Just prog <- getValue progElem
            setProp resultElem "innerHTML" (runPail prog)
