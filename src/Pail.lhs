> module Pail where

Pail
====

Pail is a programming language based on pairs; just as Lisp stands for
*LIS*t *P*rocessing, Pail stands for *PAI*r *L*anguage.

Pail's original working title was "Bizaaro[sic]-Pixley", as it resembles
Pixley in many ways, but everything's all changed around and made wicked
funny, man.

(If you don't know anything about Pixley, just know that it's a tiny subset
of Scheme.)

The first way in which Pail is "Bizaaro" is that while Pixley structures are
expressed solely with lists (proper ones, too,) Pail structures are expressed
solely with pairs.  So where Pixley has `car` and `cdr`, Pail has `fst` and
`snd`.

The second and more significant way is that while Pixley, like Scheme
and Lisp, is "evaluate-first-quote-only-when-asked", Pail is "quote-first-
evaluate-only-when-asked".  What this means is, when Pixley sees:

    (+ 1 2)

...it evaluates `+` to get a function (addition), `1` to get the number one,
`2` to get the number two, then applies the function to the arguments to
arrive at the result (the number three.)  If you wanted to arrive at the
result `(+ 1 2)`, you would have to say:

    (quote (+ 1 2))

On the other hand, when Pail sees:

    [add [1 2]]

It evaluates to exactly that,

    [add [1 2]]

In order to get Pail to look at that structure as an expression and evaluate
it, you need to wrap it in an evaluation.  Each kind of term is evaluated
slightly differently (symbols evaluate to what they're bound to, pairs
recursively evaluate their contents, etc.), so to get Pail to evaluate that
term like Pixley would do straight off, you would have to say:

    *[*add [1 2]]

If the 1 and 2 weren't literal integers, but rather bound variables, you
would need even more asterisks in there.

A third and fairly minor way is related to how bindings are created.
Noting that Haskell lets you say awesome things like

    let 2 + 2 = 5 in 2 + 2

and

    let in 5

(the latter apparently being in emulation of Scheme's allowing an empty
list of bindings, i.e. `(let () 5)`), it struck the author that, in order
for this senselessness to be total, you ought also to be able to say

    let let a = b in a = 5 in b

Alas, Haskell does not allow this.  Pail, however, does.

I don't actually know how to do recursion in Pail yet; I think you can,
somehow, by using `let`s and evaluations and `uneval`, but I haven't actually
constructed the equivalent of a recursive function with that.  So it might
be the case that in some future version, a lambda form (or, hopefully,
something even more interesting) will be added.

In this respect, and in the "`let let a = b`" circumstance, Pail echoes an
earlier attempt of mine to create a reflective rewriting language called Rho.
I didn't ever really figure out how to program in Rho, and I really haven't
figured out how to program in Pail.  But maybe someone else will, and maybe
that will shed some more light on Rho.

What follows is `Pail.lhs`, the reference implementation of the Pail
programming language.

> import Text.ParserCombinators.Parsec
> import qualified Data.Map as Map


Definitions
===========

An environment maps names (represented as strings) to expressions.

> type Env = Map.Map String Expr

A symbol is an expression.

> data Expr = Symbol String

If a and b are expressions, then a pair of a and b is an expression.

>           | Pair Expr Expr

If a is an expression, then the evaluation of a is an expression.

>           | Eval Expr

If f is a function that takes an environment and an expression
to an expression, then f is an expression.  f may optionally
be associated with a name (represented as a string) for to make
depiction of expressions more convenient, but there is no language-
level association between the function and its name.

>           | Fn String (Env -> Expr -> Expr)

Nothing else is an expression.

See below for how expressions are denoted.  We will mention only here
that functions cannot strictly speaking be denoted directly, but for
convenience, functions with known names can be represented by `<foo>`,
where `foo` is the name of the function.

> instance Show Expr where
>     show (Symbol s) = s
>     show (Pair a b) = "[" ++ (show a) ++ " " ++ (show b) ++ "]"
>     show (Eval x)   = "*" ++ (show x)
>     show (Fn n _)   = "<" ++ n ++ ">"

> instance Eq Expr where

Two symbols are equal if the strings by which they are represented
are equal.

>     (Symbol s) == (Symbol t)     = s == t

Two pairs are equal if their contents are pairwise equal.

>     (Pair a1 b1) == (Pair a2 b2) = (a1 == a2) && (b1 == b2)

Two evaluations are equal if their contents are equal.

>     (Eval x) == (Eval y)         = x == y

Two functions are never considered equal.

>     (Fn n _) == (Fn m _)         = False


Parser
======

The overall grammar of the language is:

    Expr ::= symbol | "[" Expr Expr "]" | "*" Expr | "#" Expr

A symbol is denoted by a string which may contain only alphanumeric
characters, hyphens, underscores, and question marks.

> symbol = do
>     c <- letter
>     cs <- many (alphaNum <|> char '-' <|> char '?' <|> char '_')
>     return (Symbol (c:cs))

A pair of expressions a and b is denoted

    [a b]

> pair = do
>     string "["
>     a <- expr
>     b <- expr
>     spaces
>     string "]"
>     return (Pair a b)

An evaluation of an expression a is denoted

    *a

> eval = do
>     string "*"
>     a <- expr
>     return (Eval a)

As a bit of syntactic sugar, the denotation

    #a

for some expression a is equivalent to the denotation

    **[*uneval a]

> uneval = do
>     string "#"
>     a <- expr
>     return (Eval (Eval (Pair (Eval (Symbol "uneval")) a)))

The top-level parsing function implements the overall grammar given above.
Note that we need to give the type of this parser here -- otherwise the
type inferencer freaks out for some reason.

> expr :: Parser Expr
> expr = do
>     spaces
>     r <- (eval <|> uneval <|> pair <|> symbol)
>     return r

A convenience function for parsing Pail programs.

> parsePail program = parse expr "" program


Evaluator
=========

We evaluate a Pail expression by reducing it.  (We use this terminology
to try to limit confusion, since "an evaluation of" is already part of our
definition of Pail expressions.)

There are two kinds of reductions in Pail: outer ("o-") reductions and inner
("i-") reductions.  So, to be more specific, we evaluate a Pail expression
by o-reducing it.  Outer reductions may involve inner reductions, which may
themselves involve further outer reductions.

Outer Reduction
---------------

An evaluation of some expression x o-reduces to the i-reduction of its
contents.

> oReduce env (Eval x)              = iReduce env x

Everything else o-reduces to itself.

> oReduce env x                     = x

Inner Reduction
---------------

A symbol i-reduces to the expression to which is it bound in the current
environment.  If it is not bound to anything, it i-reduces to itself.

> iReduce env (Symbol s)        = Map.findWithDefault (Symbol s) s env

A pair where the LHS is a function i-reduces to the application of that
function to the RHS of the pair, in the current function.

> iReduce env (Pair (Fn _ f) b) = f env b

Any other pair i-reduces to a pair with pairwise o-reduced contents.

> iReduce env (Pair a b)        = Pair (oReduce env a) (oReduce env b)

The inner reduction of an evaluation of some expression x is the i-reduction
of x, i-reduced one more time.

> iReduce env (Eval x)          = iReduce env (iReduce env x)


Standard Environment
====================

Applying any of these functions to any type of argument which is not
defined here (for example, applying `fst` to a non-pair) is an error;
evaluation terminates immediately with an error term or message.

Again, to try to limit confusion (I must not say "reduce confusion" or
things will get even worse), we use the terminology that a function
"returns" a value here, rather than "reducing" or "evaluating" to one.

Applying `fst` to a pair (resp. `snd`) returns the o-reduction of the
first (resp. second) element of that pair.

> pFst env (Pair a _)                           = oReduce env a
> pSnd env (Pair _ b)                           = oReduce env b

Applying `ifequal` to a pair of pairs proceeds as follows.  The contents
of the first pair are compared for (deep) equality.  If they are equal,
the o-reduction of the first element of the second pair is returned; if not,
the o-reduction of the second element of the second pair is returned.

> pIfEqual env (Pair (Pair a b) (Pair yes no))
>                                   | a == b    = oReduce env yes
>                                   | otherwise = oReduce env no

Applying `typeof` to a value of any kind returns a symbol describing
the type of that value.  For symbol, `symbol` is returned; for pairs,
`pair`; for evaluations, `eval`; and for functions, `function`.

> pTypeOf env (Symbol _)                        = Symbol "symbol"
> pTypeOf env (Pair _ _)                        = Symbol "pair"
> pTypeOf env (Eval _)                          = Symbol "eval"
> pTypeOf env (Fn _ _)                          = Symbol "function"

Applying `uneval` to an expression returns the evaluation of that
expression.  (Note that nothing is reduced in this process.)

> pUnEval env x                                 = Eval x

Applying `let` to a pair of a pair (called the "binder") and an expression
returns the o-reduction of that expression in a new environment, constructed
as follows.  The first element of the binder is o-reduced to obtain a symbol;
the second element of the binder is o-reduced to obtain a value of any type.
A new environment is created; it is just like the current evironment except
with the obtained symbol bound to the obtained value.

> pLet env (Pair (Pair name binding) expr)      =
>     let
>         (Symbol sym) = oReduce env name
>         val          = oReduce env binding
>         env'         = Map.insert sym val env
>     in
>         oReduce env' expr

And finally, we define the standard environment by associating each of the
above defined functions with a symbol.

> stdEnv :: Env
> stdEnv = Map.fromList (map (\(name, fun) -> (name, (Fn name fun)))
>     [
>       ("fst",        pFst),
>       ("snd",        pSnd),
>       ("if-equal?",  pIfEqual),
>       ("type-of",    pTypeOf),
>       ("uneval",     pUnEval),
>       ("let",        pLet)
>     ])


Top-Level Driver
================

Note that if this driver is given text which it cannot parse, it will
evaluate to a string which contains the parse error message and always
begins with '%'.  No Pail expression can begin with this character, so
parse errors can be detected unambiguously.

> runPail line =
>     case (parse expr "" line) of
>         Left err -> "%" ++ (show err)
>         Right x -> show (oReduce stdEnv x)

Happy bailing!  
Chris Pressey  
Evanston, Illinois  
May 27, 2011
