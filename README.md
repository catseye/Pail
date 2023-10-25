Pail
====

_Try it online_ [@ catseye.tc](https://catseye.tc/installation/Pail)
| _Wiki entry_ [@ esolangs.org](https://esolangs.org/wiki/Pail)
| _See also:_ [Pixley](https://codeberg.org/catseye/Pixley#pixley)
∘ [Quylthulg](https://codeberg.org/catseye/Quylthulg#the-quylthulg-programming-language)

- - - -

Pail is an esoteric programming language based on pairs; just as Lisp
stands for *LIS*t *P*rocessing, Pail stands for *PAI*r *L*anguage.

This is the reference distribution for Pail.

The Pail programming language is documented in the literate Haskell
source code of its reference interpreter, `Pail.lhs`, which can be
found in the `src/Language` subdirectory:

*   [src/Language/Pail.lhs](src/Language/Pail.lhs)

The literate Haskell was written as if it were Markdown, so you might
(or might not) have luck looking at it as such in a browsing interface:

*   [Language.Pail](src/Language/)

Some tests, in [Falderal][] format, which might clarify the intended
behaviour, can be found in `Pail.md` in the `tests` subdirectory:

*   [tests/Pail.md](tests/Pail.md)

These files are distributed under a 3-clause BSD license.  See the file
`LICENSE` for the license text.

There is also a demonstration of running the Pail interpreter in
a web browser, by compiling the reference implementation to Javascript
with the [Haste][] compiler.  You can try this locally by building
`demo/pail.js` and opening `demo/pail.html` in a web browser.

More information
----------------

For more information on the language, see the [Pail][] entry at
Cat's Eye Technologies.

[Pail]: https://catseye.tc/node/Pail
[Falderal]: https://catseye.tc/node/Falderal
[Haste]: https://haste-lang.org/
