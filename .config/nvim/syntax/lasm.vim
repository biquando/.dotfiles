" Vim syntax file
" Language: lasm

if exists("b:current_syntax")
	finish
endif

syn keyword lasmInstruction load store mod cond sig nop
syn keyword lasmMacro GOTO RAW INT CHA STR PSH POP CALL RET INC DEC TRA
syn keyword lasmDirective global const
syn match lasmComment "\/\/.*$"
syn match lasmLabel "\$\w\+"
syn match lasmLabelDef "^\s*\$\w\+"
syn match lasmNumber "[0-9]\+"
syn match lasmNumber "0x[0-9a-fA-F]\+"
syn match lasmRaw "\([0-9a-fA-F]\{2}[ ]\)*\([0-9a-fA-F]\{2}\)"
syn region lasmString start="\"" end="\"" skip="\\\""
syn region lasmChar start="\'" end="\'" skip="\\\'"
syn keyword lasmRegister ra rb rc rd rx rar rsp rip ha hb hc hd hx har hsp hip
syn keyword lasmSignal out abort

let b:current_syntax = "lasm"

" Normal: white
" PreProc: tan
" Comment: gray
" Constant: blue
" Number: orange
" String: green
" Keyword: red
" Statement: purple
" jsTemplateBraces: dark red
hi def link lasmInstruction   Keyword
hi def link lasmMacro         jsTemplateBraces
hi def link lasmDirective     jsTemplateBraces
hi def link lasmComment       Comment
hi def link lasmLabel	      Type
hi def link lasmLabelDef      Identifier
hi def link lasmNumber        Number
hi def link lasmRaw           Number
hi def link lasmString        String
hi def link lasmChar          String
hi def link lasmRegister      Constant
hi def link lasmSignal        Normal
