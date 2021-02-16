" Boilerplate {{{1
if exists("b:loaded_foldmk")
    finish
endif
let b:loaded_foldmk = 1

" Private interface {{{1
" Options {{{2

" Default settings for foldmk
let s:foldmkdefault = {
            \"indent": 4,
            \"indenttext": " ",
            \"layout": "[+] %t %f (%l)",
            \}

" Functions {{{2

" Get any set options, otherwise use the defaults
function s:Option(option)
    if has_key(g:foldmk, a:option)
        return g:foldmk[a:option]
    endif
    return s:foldmkdefault[a:option]
endfunction!

" Get how many screen columns are usable for text
function! s:UsableColumns(win)
    let ret = winwidth(a:win)
    let ret -= &foldcolumn

    if &number || &relativenumber
        let ret -= max([&numberwidth, strlen(line('$')) + 1])
    endif

    if len(sign_getplaced()) > 0 && &signcolumn ==? "auto"
                \|| &signcolumn ==?  "yes"
        let ret -= 2
    endif

    return ret
endfunction

" Get the fillchar for folds, defaulting to space if it doesn't exist
function! s:GetFoldChar()
    let ret = " "
    let fills = split(&fillchars, ",")

    for char in fills
        let [key, value] = split(char, ":")
        if key ==? "fold"
            let ret = value
            break
        endif
    endfor

    return ret
endfunction

" Replace first occurrence of any token in tokens
function! s:ReplaceFirst(string, tokens, substitutions, start)
    let idx = s:FindFirstIndex(a:string, a:tokens, a:start)
    let newtext = a:string[a:start :]
    let substitution = a:substitutions[idx]
    let token = a:tokens[idx]
    let nextsearchstart = match(a:string, token, a:start)
    let newtext = substitute(newtext, token, substitution, '')
    if a:start > 0
        let newtext = a:string[: a:start - 1] .. newtext
    endif

    let ret = [newtext, nextsearchstart]

    " %% is a special case, only increment 1
    if token == "%%"
        let ret[1] += 1
    else
        let ret[1] += strlen(substitution)
    endif
    return ret

endfunction

" Find first occurrence of any string in needles in haystack
function! s:FindFirstIndex(haystack, needles, start)
    let idxs = []
    for needle in a:needles
        let idxs += [stridx(a:haystack, needle, a:start)]
    endfor
    call map(idxs, { idx, val -> val < 0 ? strlen(a:haystack) : val })
    let idx = index(idxs, min(idxs))
    return idxs[idx] == strlen(a:haystack) ? -1 : idx
endfunction

" Glue together the parts for the final fold text
function! s:RenderFoldText(indent, text, linecount)
    let nonconf = substitute(s:Option("layout"), "%[%tfl]", "", "g")
    let fill = s:UsableColumns(0)
                \- strlen(nonconf)
                \- strlen(a:indent)

    " Support multiple fills, fold text, and linecounts
    let textcount = count(s:Option("layout"), "%t")
    let linecountcount = count(s:Option("layout"), "%l")
    let fillcount = count(s:Option("layout"), "%f")
    let percentcount = count(s:Option("layout"), "%%")

    let fill -= textcount * strlen(a:text)
    let fill -= linecountcount * strlen(a:linecount)
    let fill -= percentcount
    let fill /= fillcount

    let finaltext = a:indent
    let filler = repeat(s:GetFoldChar(), fill)
    let addedfill = 0

    let textbuild = s:Option("layout")
    let start = 0
    let prevlen = -1
    while strlen(textbuild) != prevlen
        let prevlen = strlen(textbuild)
        let [textbuild, l:start] = s:ReplaceFirst(
                    \textbuild,
                    \["%%", "%f", "%t", "%l"],
                    \["%", l:filler, a:text, a:linecount],
                    \l:start)
    endwhile

    let finaltext ..= textbuild

    " Hack for when things don't divide out nicely with multiple %f's
    if strlen(finaltext) < s:UsableColumns(0)
        let padding = repeat(s:GetFoldChar(), 1 + s:UsableColumns(0) - strlen(finaltext))
        let finaltext = substitute(finaltext, s:GetFoldChar(), padding, "")
    endif

    return finaltext
endfunction

" Public interface {{{1
" Options {{{2

" Use default settings unless user has customized them
if !exists('g:foldmk')
    let g:foldmk = s:foldmkdefault
endif

" Functions {{{2

function! FoldmkFoldText()
    let text = foldtext()
    let indent = repeat(s:Option("indenttext"), (v:foldlevel - 1) * s:Option("indent"))
    let text = trim(substitute(text, "^+-*", "", ""))
    let linecount = trim(split(text, ":")[0])
    let text = text[stridx(text, ":")+2:]
    return s:RenderFoldText(indent, text, linecount)
endfunction

" vim:fdm=marker:fdl=0
