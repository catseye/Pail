Test Suite for Pail
===================

This test suite is written in the format of Falderal 0.7.  It is far from
exhaustive, but provides a basic sanity check that the language I've designed
here comes close to what I had in mind.

Pail Tests
----------

    -> Tests for functionality "Evaluate Pail Expression"

    -> Functionality "Evaluate Pail Expression" is implemented by
    -> shell command
    -> "ghc -e "do c <- readFile \"%(test-file)\"; putStrLn $ Pail.runPail c" Pail.lhs"

A symbol reduces to that symbol.

    | fst
    = fst

    | plains-of-leng?
    = plains-of-leng?

A symbol must begin with a letter and contain only letters, digits,
hyphens, and question marks.

    | ^hey
    = %(line 1, column 1):
    = unexpected "^"
    = expecting white space, "*", "#", "[" or letter

A pair reduces to that pair.

    | [a b]
    = [a b]

    | [fst [a b]]
    = [fst [a b]]

    | [*fst [a b]]
    = [*fst [a b]]

Square brackets must be properly matched.

    | [a b
    = %(line 1, column 5):
    = unexpected end of input
    = expecting letter or digit, "-", "?", "_", white space or "]"

Evaluation of a symbol reduces to that to which it is bound.

    | *fst
    = <fst>

Evaluation of a pair recursively reduces its contents.

    | *[*fst [a b]]
    = [<fst> [a b]]

    | *[*fst *snd]
    = [<fst> <snd>]

    | *[*fst *[*snd *fst]]
    = [<fst> [<snd> <fst>]]

Evaluation of a pair w/a fun on the lhs applies the fun.

    | **[*fst [a b]]
    = a

    | **[*snd [a b]]
    = b

Reducing an evaluation of a pair can accomplish a cons.

    | *[**[*fst [a b]] **[*snd [c d]]]
    = [a d]

Reducing on the lhs of a pair can obtain a fun to apply.

    | **[**[*fst [*snd *fst]] [a b]]
    = b

Applying uneval reduces to an evaluation.

    | **[*uneval hello]
    = *hello

The form `#x` is syntactic sugar for `**[*uneval x]`.

    | #hello
    = *hello

Syntactic sugar is expanded at parse time.

    | [#fst [a b]]
    = [**[*uneval fst] [a b]]

It is possible to uneval a fun.

    | #*fst
    = *<fst>

Reduction of an uneval'ed symbol can be used to obtain an eval'ed symbol.

    | *[#fst [a b]]
    = [*fst [a b]]

Reduction of uneval'ed symbol can be used to obtain a fun.

    | **[#fst [a b]]
    = [<fst> [a b]]

Reduction of uneval'ed symbol can be used to apply the obtained fun.

    | ***[#fst [a b]]
    = a

Positive test of `if-equal?` on symbols.

    | **[*if-equal? [[a a] [one two]]]
    = one

Negative test of `if-equal?` on symbols.

    | **[*if-equal? [[a b] [one two]]]
    = two

Negative test of `if-equal?` on evals.

    | ***[*if-equal? [[*a *b] [fst snd]]]
    = <snd>

Let can bind a symbol to a symbol.

    | **[*let [[a b] *a]]
    = b

Let can bind a symbol to a pair.

    | **[*let [[g [x y]] **[*snd *g]]]
    = y

Let can bind a symbol to an expression containing an uneval,
which can at a later point be eval'ed and reduced.

    | **[*let [
    |      [sndg *[**[*uneval snd] **[*uneval g]]]
    |      **[*let [
    |           [g [x y]]
    |           ***sndg
    |        ]]
    |   ]]
    = y

    | **[*let [
    |      [cadrg *[#fst ##*[#snd #g]]]
    |      **[*let [
    |           [g [x [y z]]]
    |           ***cadrg
    |        ]]
    |   ]]
    = y

Let can bind uneval'ed expression; prior bindings are honoured.

    | **[*let [
    |      [g moo]
    |      **[*let [
    |           [consnull *[#g null]]
    |           ***consnull
    |        ]]
    |   ]]
    = [moo null]

Let can bind uneval'ed expression; prior bindings are shadowed.

    | **[*let [
    |      [g moo]
    |      **[*let [
    |           [consnull *[#g null]]
    |           **[*let [
    |                [g k]
    |                 ***consnull
    |             ]]
    |        ]]
    |   ]]
    = [k null]
