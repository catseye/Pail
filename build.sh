#!/bin/sh

PROG=pail

if command -v ghc >/dev/null 2>&1; then
    echo "building $PROG.exe with ghc"
    (cd src && ghc --make Main.hs -o ../bin/$PROG.exe)
else
    echo "ghc not found, not building $PROG.exe"
fi

# For this to work, you need hastec installed.
# You also need parsec installed in a way that haste can use it:
#
#    haste-cabal install parsec-3.1.1
#
# Later versions might not work.  For example, 3.1.13.0 fails to build for me at:
# Preprocessing library generic-deriving-1.12.3...
# src/Generics/Deriving/TH/Pre4_9.hs:177:20:
#     parse error on input ‘->’
#

if command -v hastec >/dev/null 2>&1; then
    echo "building $PROG.js with hastec"
    (cd src && hastec --make HasteMain.hs -o $PROG.js && mv $PROG.js ../demo/)
else
    echo "hastec not found, not building $PROG.js"
fi
