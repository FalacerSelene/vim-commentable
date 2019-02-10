"|===========================================================================|
"|                                                                           |
"|         FILE:  plugin/commentable.vim                                     |
"|                                                                           |
"|  DESCRIPTION:  Main entrance point for plugin. Adds utilities for block   |
"|                commenting.                                                |
"|                                                                           |
"|       AUTHOR:  @FalacerSelene                                             |
"|      CONTACT:  < git at falacer-selene dot net >                          |
"|      LICENCE:  See LICENCE.md                                             |
"|      VERSION:  0.3.2 <alpha>                                              |
"|                                                                           |
"|===========================================================================|

"|===========================================================================|
"|                                  SETUP                                    |
"|===========================================================================|
scriptencoding utf-8

if &compatible || exists('g:loaded_commentable')
	finish
elseif v:version < 704
	echoerr 'Commentable requires vim 7.4 or later!'
endif

let g:loaded_commentable = 1
let g:commentable_version = '0.3.2'
lockvar g:commentable_version

"|===========================================================================|
"|                             USER INTERFACE                                |
"|===========================================================================|

"|===========================================================================|
"| CommentableReformat                                                       |
"|===========================================================================|
command -nargs=0 -range -bar CommentableReformat
	\ <line1>,<line2>call <SID>Reformat(0)
nnoremap <silent><unique> <Plug>(CommentableReformat)
	\ :<c-u>call <SID>Reformat(1)<CR>
vnoremap <silent><unique> <Plug>(CommentableReformat)
	\ :<c-u>'<,'>call <SID>Reformat(1)<CR>

"|===========================================================================|
"| CommentableCreate                                                         |
"|===========================================================================|
command -nargs=0 -range -bar CommentableCreate
	\ <line1>,<line2>call <SID>CreateBlock(0)
nnoremap <silent><unique> <Plug>(CommentableCreate)
	\ :<c-u>call <SID>CreateBlock(1)<CR>
vnoremap <silent><unique> <Plug>(CommentableCreate)
	\ :<c-u>'<,'>call <SID>CreateBlock(1)<CR>

"|===========================================================================|
"| CommentableSetDefault...                                                  |
"|===========================================================================|
command -nargs=0 -bar CommentableSetDefaultStyle call <SID>SetDefStyle()
command -nargs=0 -bar CommentableSetDefaultBindings call <SID>SetDefBindings()

"|===========================================================================|
"|                            SCRIPT FUNCTIONS                               |
"|===========================================================================|

"|===========================================================================|
"| s:SetDefStyle() {{{                                                       |
"|                                                                           |
"| Set default style parameters.                                             |
"|===========================================================================|
function s:SetDefStyle()
	let g:CommentableBlockStyle  = ['#', '', '']
	let g:CommentableBlockColumn = 80
	augroup Commentable
		autocmd!
		autocmd FileType python let b:CommentableBlockStyle = ['#' , '-', ''  ]
		autocmd FileType perl   let b:CommentableBlockStyle = ['#*', '*', '*#']
		autocmd FileType sh     let b:CommentableBlockStyle = ['#' , '#', '#' ]
		autocmd FileType c      let b:CommentableBlockStyle = ['/*', '*', '*/']
		autocmd FileType cpp    let b:CommentableBlockStyle = ['/*', '*', '*/']
		autocmd FileType java   let b:CommentableBlockStyle = ['//', '-', '//']
		autocmd FileType scheme let b:CommentableBlockStyle = [';;', '-', ';;']
		autocmd FileType vim    let b:CommentableBlockStyle = ['"' , '-', ''  ]
		autocmd FileType make   let b:CommentableBlockStyle = ['#' , '-', ''  ]
		autocmd FileType python let b:CommentableBlockWidth = 79
	augroup END
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:SetDefBindings() {{{                                                    |
"|                                                                           |
"| Set default keybindings.                                                  |
"|===========================================================================|
function s:SetDefBindings()
	nmap gcc <Plug>(CommentableCreate)
	nmap gcq <Plug>(CommentableReformat)
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:Reformat(setrepeat) range {{{                                           |
"|                                                                           |
"| Reformat the current block at the current location, or if a range is      |
"| given, then reformat all comment blocks within the range.                 |
"|                                                                           |
"| PARAMS:                                                                   |
"|   setrepeat) If 1, set vim-repeat's '.' command.                          |
"|                                                                           |
"| Returns nothing. May error, if a lower exception propagate upwards.       |
"|===========================================================================|
function s:Reformat(setrepeat) range
	try
		execute a:firstline . ',' . a:lastline 'call commentable#Reformat()'
	catch
		echoerr v:exception
	endtry

	"|===============================================|
	"| Set '.' command if we have the right plugin.  |
	"|===============================================|
	if a:setrepeat == 1
		silent! call repeat#set("\<Plug>(CommentableReformat)")
	endif
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:CreateBlock(setrepeat) range {{{                                        |
"|                                                                           |
"| Create a new comment block comprising the text in the given range.        |
"|                                                                           |
"| PARAMS:                                                                   |
"|   setrepeat) If 1, set vim-repeat's '.' command.                          |
"|                                                                           |
"| Returns nothing. May error, if a lower exception propagate upwards.       |
"|===========================================================================|
function s:CreateBlock(setrepeat) range
	try
		execute a:firstline . ',' . a:lastline 'call commentable#CreateBlock()'
	catch
		echoerr v:exception
	endtry

	if a:setrepeat == 1
		silent! call repeat#set("\<Plug>(CommentableCreate)")
	endif
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
