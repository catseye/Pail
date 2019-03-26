examplePrograms = [
    {
        "contents": "***[#fst [a b]]\n", 
        "filename": "apply-fun.pail"
    }, 
    {
        "contents": "*[**[*fst [a b]] **[*snd [c d]]]\n", 
        "filename": "cons.pail"
    }, 
    {
        "contents": "[#fst [a b]]\n", 
        "filename": "hash-sugar.pail"
    }, 
    {
        "contents": "**[*let [[a b] *a]]\n", 
        "filename": "let-basic.pail"
    }, 
    {
        "contents": "**[*let [\n     [sndg *[**[*uneval snd] **[*uneval g]]]\n     **[*let [\n          [g [x y]]\n          ***sndg\n       ]]\n  ]]\n", 
        "filename": "let-evaled.pail"
    }, 
    {
        "contents": "**[*let [\n     [g moo]\n     **[*let [\n          [consnull *[#g null]]\n          ***consnull\n       ]]\n  ]]\n", 
        "filename": "let-unevaled.pail"
    }
];
