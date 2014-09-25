#!/bin/sh

if [ x`which ghc` = x -a x`which runhugs` = x ]; then
    echo "Neither ghc nor runhugs found on search path"
    exit 1
fi

touch fixture.markdown

if [ ! x`which ghc` = x ]; then
    cat >>fixture.markdown <<EOF
    -> Functionality "Evaluate Pail Expression" is implemented by
    -> shell command
    -> "ghc -e "do c <- readFile \"%(test-body-file)\"; putStrLn $ Pail.runPail c" src/Pail.lhs"

EOF
fi

if [ ! x`which runhugs` = x ]; then
    cat >>fixture.markdown <<EOF
    -> Functionality "Evaluate Pail Expression" is implemented by
    -> shell command
    -> "runhugs src/Main.hs %(test-body-file)"

EOF
fi

falderal fixture.markdown tests/Pail.markdown
RESULT=$?
rm -f fixture.markdown
exit $RESULT
