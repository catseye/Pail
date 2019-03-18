#!/bin/sh

# For this to work, you need hastec installed.
# You also need parsec installed so that haste can use it:
#
#    haste-cabal install parsec-3.1.1
#
# Later versions may not work.  For example, 3.1.13.0 fails to build for me at:
# Preprocessing library generic-deriving-1.12.3...
# src/Generics/Deriving/TH/Pre4_9.hs:177:20:
#     parse error on input ‘->’
#

if command -v hastec > /dev/null 2>&1; then
  (cd src && hastec HasteMain.hs -o ../demo/pail.js )
else
  echo "hastec not found, not building pail.js"
fi
