" Vim syntax file
" Language: latex

if exists("b:current_syntax")
  finish
endif

syntax match latexComment "%.*$"
syntax match latexCommand "\\."
syntax match latexCommand "\\[A-Za-z@]\+"
syntax match latexBegin "\\begin{[^}]*}"
syntax match latexEnd "\\end{[^}]*}"
syntax region latexMathInline start="\$" end="\$" keepend
syntax region latexMathDisplay start="\\\[" end="\\\]" keepend
syntax region latexMathDisplay start="\$\$" end="\$\$" keepend
syntax match latexBrace "[{}]"

" Highlight groups
highlight default link latexComment Comment
highlight default link latexCommand Function
highlight default link latexBegin Added
highlight default link latexEnd Removed
highlight default link latexMathInline Special
highlight default link latexMathDisplay Special
highlight default link latexBrace Delimiter

let b:current_syntax = "latex"
