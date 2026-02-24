" brulee.vim - mid-contrast french cartoon midnight colorscheme
" author: @kmitrich

" #fbeab7 - main fg
" #03142a - main bg
" #00ff00 - comment
" #ffffff - accent color 0
" #ffff7f - accent color 1

hi clear
syntax reset
let g:colors_name = "brulee"
set background=dark
set t_Co=256

hi Normal guifg=#fbeab7 ctermbg=NONE guibg=#03142a gui=NONE

hi DiffText guifg=#ffffff guibg=NONE
hi ErrorMsg guifg=#ffffff guibg=NONE
hi WarningMsg guifg=#ffffff guibg=NONE
hi PreProc guifg=#ffffff guibg=NONE
hi Exception guifg=#ffffff guibg=NONE
hi Error guifg=#ffffff guibg=NONE
hi DiffDelete guifg=#ffffff guibg=NONE
hi GitGutterDelete guifg=#ffffff guibg=NONE
hi GitGutterChangeDelete guifg=#ffffff guibg=NONE
hi cssIdentifier guifg=#ffffff guibg=NONE
hi cssImportant guifg=#ffffff guibg=NONE
hi Type guifg=#ffffff guibg=NONE gui=bold
hi Identifier guifg=#fbeab7 guibg=NONE
hi PMenuSel guifg=#ffff7f guibg=NONE
hi Constant guifg=#ffff7f guibg=NONE gui=BOLD
hi Repeat guifg=#ffff7f guibg=NONE
hi DiffAdd guifg=#ffff7f guibg=NONE
hi GitGutterAdd guifg=#ffff7f guibg=NONE
hi cssIncludeKeyword guifg=#ffff7f guibg=NONE
hi Keyword guifg=#ffff7f guibg=NONE gui=BOLD
hi IncSearch guifg=#ffffff guibg=NONE
hi Title guifg=#ffffff guibg=NONE
hi PreCondit guifg=#ffffff guibg=NONE
hi Debug guifg=#ffffff guibg=NONE
hi SpecialChar guifg=#ffffff guibg=NONE
hi Conditional guifg=#ffffff guibg=NONE
hi Todo guifg=#ffffff guibg=NONE
hi Special guifg=#ffffff guibg=NONE
hi Label guifg=#ffffff guibg=NONE
hi Delimiter guifg=#ffffff guibg=NONE
hi Number guifg=#ffffff guibg=NONE gui=bold
hi CursorLineNR guifg=#ffffff guibg=NONE
hi Define guifg=#ffffff guibg=NONE
hi MoreMsg guifg=#ffffff guibg=NONE
hi Tag guifg=#ffffff guibg=NONE
hi String guifg=#ffffff guibg=NONE gui=bold
hi MatchParen guifg=#ffffff guibg=NONE
hi Macro guifg=#ffffff guibg=BOLD
hi DiffChange guifg=#ffffff guibg=NONE
hi GitGutterChange guifg=#ffffff guibg=NONE
hi cssColor guifg=#ffffff guibg=NONE
hi Function guifg=#fbeab7 guibg=NONE
hi Directory guifg=#ffff7f guibg=NONE
hi markdownLinkText guifg=#ffff7f guibg=NONE
hi javaScriptBoolean guifg=#ffff7f guibg=NONE
hi Include guifg=#ffff7f guibg=NONE
hi Storage guifg=#ffff7f guibg=NONE
hi cssClassName guifg=#ffff7f guibg=NONE
hi cssClassNameDot guifg=#ffff7f guibg=NONE
hi Statement guifg=#fbeab7 guibg=NONE
hi Operator guifg=#fbeab7 guibg=NONE
hi cssAttr guifg=#fbeab7 guibg=NONE

hi Pmenu guifg=#fbeab7 guibg=#03142a
hi SignColumn guibg=#03142a
hi Title guifg=#fbeab7
hi LineNr guifg=#fbeab7 guibg=#03142a
hi NonText guifg=#00ff00 guibg=#03142a
hi Comment guifg=#00ff00 gui=NONE
hi SpecialComment guifg=#00ff00 gui=NONE guibg=NONE
hi CursorLine guibg=#33445a
hi TabLineFill gui=NONE guibg=#03142a
hi TabLine guifg=#ee9017 guibg=#03142a gui=NONE
hi StatusLine gui=bold guibg=#fbeab7 guifg=#03142a
hi StatusLineNC gui=NONE guibg=#03142a guifg=#fbeab7
hi Search guibg=#fbeab7 guifg=#03142a
hi VertSplit gui=NONE guifg=#03142a guibg=NONE
hi Visual gui=NONE guifg=#03142a guibg=#fbeab7

