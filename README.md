# foldmk - A simple foldtext customizer

This is a small plugin I wrote simply because I like to tinker with stuff and
the code for my fold text ended up taking up some space in my vimrc, so I
figured I'd just put it together into a plugin.

foldmk lets you customize the foldtext vim displays in a simpler way than
writing custom functions. Simply install this plugin and add the line `set
foldtext=FoldmkFoldText()` to your .vimrc and you're up and running with the
default settings.

## Comparison with default vim foldtext

vim default foldtext                    | foldmk default foldtext
----------------------------------------|----------------------------------------------
`+-- 10 lines: Folded text -----------` | `[+] Folded text ---------------- (10 lines)`

## Configuration

Want to change the look? The configuration is handled by 3 variables:

    - `g:foldmk.indent` sets the indentation of nested folds (default: 4)
    - `g:foldmk.indenttext` sets what text to use for indentation (default: " ")
    - `g:foldmk.layout` sets the order of the foldtext elements (default: "[+] t f (l)")

`g:foldmk.layout` treats the letters `t`, `f`, and `l` specially. `t` will
insert the text of the first line of the fold. `l` will insert the text `x
lines`, where `x` of course is the number of lines contained in the fold. `f`
will fill out the rest of the space by inserting the character determined by
vim's `fillchars` option (defaulting to space if there's no fold option set).
Any other characters in the string are printed as-is.

So to change anything, simply add `let <config>=<new value>` into your vimrc for
what you want to change (or set the variables in a running vim session to experiment).

## Example layouts

Layout string | Result
------------- | ------
`"[+] t f (l)"` | <pre>`[+] Folded text -------------------- (10 lines)`</pre>
`"t: l"`        | <pre>`Folded text: 10 lines                          `</pre>
`"f t"`         | <pre>`----------------------------------- Folded text`</pre>
`"... l ..."`   | <pre>`... 10 lines ...                               `</pre>
