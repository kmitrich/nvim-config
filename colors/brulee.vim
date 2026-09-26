" brulee.vim - mid-contrast french cartoon midnight colorscheme
" author: @kmitrich

" #fbeab7 - main fg
" #03142a - main bg
" #00ff00 - comment
" #eaeaea - accent color 0
" #efef5f - accent color 1

hi clear
syntax reset
let g:colors_name = "brulee"
set background=dark
set t_Co=256

hi Normal guifg=#fbeab7 ctermbg=NONE guibg=#01112a gui=NONE

hi DiffText guifg=#eaeaea guibg=NONE
hi ErrorMsg guifg=#eaeaea guibg=NONE
hi WarningMsg guifg=#eaeaea guibg=NONE
hi PreProc guifg=#eaeaea guibg=NONE
hi Exception guifg=#eaeaea guibg=NONE
hi Error guifg=#eaeaea guibg=NONE
hi DiffDelete guifg=#eaeaea guibg=NONE
hi GitGutterDelete guifg=#eaeaea guibg=NONE
hi GitGutterChangeDelete guifg=#eaeaea guibg=NONE
hi cssIdentifier guifg=#eaeaea guibg=NONE
hi cssImportant guifg=#eaeaea guibg=NONE
hi Type guifg=#eaeaea guibg=NONE gui=NONE
hi Identifier guifg=#fbeab7 guibg=NONE
hi PMenuSel guifg=#efef5f guibg=NONE
hi Constant guifg=#efef5f guibg=NONE gui=NONE
hi Repeat guifg=#efef5f guibg=NONE
hi DiffAdd guifg=#efef5f guibg=NONE
hi GitGutterAdd guifg=#efef5f guibg=NONE
hi cssIncludeKeyword guifg=#efef5f guibg=NONE
hi Keyword guifg=#efef5f guibg=NONE gui=NONE
hi IncSearch guifg=#eaeaea guibg=NONE
hi Title guifg=#eaeaea guibg=NONE
hi PreCondit guifg=#eaeaea guibg=NONE
hi Debug guifg=#eaeaea guibg=NONE
hi SpecialChar guifg=#eaeaea guibg=NONE
hi Conditional guifg=#eaeaea guibg=NONE
hi Todo guifg=#eaeaea guibg=NONE
hi Special guifg=#eaeaea guibg=NONE
hi Label guifg=#eaeaea guibg=NONE
hi Delimiter guifg=#eaeaea guibg=NONE
hi Number guifg=#eaeaea guibg=NONE gui=NONE
hi CursorLineNR guifg=#eaeaea guibg=NONE
hi Define guifg=#eaeaea guibg=NONE
hi MoreMsg guifg=#eaeaea guibg=NONE
hi Tag guifg=#eaeaea guibg=NONE
hi String guifg=#eaeaea guibg=NONE gui=NONE
hi MatchParen guifg=#eaeaea guibg=NONE
hi Macro guifg=#eaeaea guibg=NONE
hi DiffChange guifg=#eaeaea guibg=NONE
hi GitGutterChange guifg=#eaeaea guibg=NONE
hi cssColor guifg=#eaeaea guibg=NONE
hi Function guifg=#fbeab7 guibg=NONE
hi Directory guifg=#efef5f guibg=NONE
hi markdownLinkText guifg=#efef5f guibg=NONE
hi javaScriptBoolean guifg=#efef5f guibg=NONE
hi Include guifg=#efef5f guibg=NONE
hi Storage guifg=#efef5f guibg=NONE
hi cssClassName guifg=#efef5f guibg=NONE
hi cssClassNameDot guifg=#efef5f guibg=NONE
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
hi StatusLine gui=BOLD guibg=#fbeab7 guifg=#03142a
hi StatusLineNC gui=BOLD guibg=#03142a guifg=#fbeab7
hi Search guibg=#fbeab7 guifg=#03142a
hi VertSplit gui=NONE guifg=#03142a guibg=NONE
hi Visual gui=NONE guifg=#03142a guibg=#fbeab7

