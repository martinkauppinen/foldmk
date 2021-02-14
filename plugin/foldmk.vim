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
            \"layout": "[+] t f (l)",
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

" Glue together the parts for the final fold text
function! s:RenderFoldText(indent, text, linecount)
    let nonconf = substitute(s:Option("layout"), "[ptfl]", "", "g")
    let fillcount = s:UsableColumns(0)
                \- strlen(nonconf)
                \- strlen(a:indent)

    " Support multiple prefix, fold text, and linecounts
    let prefixcount = count(s:Option("layout"), "p")
    let textcount = count(s:Option("layout"), "t")
    let linecountcount = count(s:Option("layout"), "l")

    let fillcount -= prefixcount * strlen(s:Option("prefix"))
    let fillcount -= textcount * strlen(a:text)
    let fillcount -= linecountcount * strlen(a:linecount)

    let finaltext = a:indent
    let fill = repeat(s:GetFoldChar(), fillcount)
    let addedfill = 0

    for char in split(s:Option("layout"), '\zs')
        if char ==# 'p'
            let finaltext ..= s:Option("prefix")
        elseif char ==# 't'
            let finaltext ..= a:text
        elseif char ==# 'f'
            " Only add fill once
            if addedfill == 0
                let finaltext ..= fill
                let addedfill = 1
            endif
        elseif char ==# 'l'
            let finaltext ..= a:linecount
        else
            let finaltext ..= char
        endif
    endfor

    " Add dummy empty fill at the end if 'f' absent from layout
    if addedfill == 0
        let finaltext ..= repeat(" ", winwidth(0))
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
