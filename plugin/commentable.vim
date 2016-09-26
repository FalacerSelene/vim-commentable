"|===========================================================================|
"| File:        commentable.vim                                              |
"| Description: Main entrance point. Adds utilities for block-commenting.    |
"| Author:      @galtish < mj dot git plus commentable at fastmail dot com > |
"| Licence:     See LICENCE.md                                               |
"| Version:     0.1.0 <indev>                                                |
"|===========================================================================|

"|===========================================================================|
"| Initial setup                                                         {{{ |
"|===========================================================================|
scriptencoding utf-8

if &compatible || exists('g:loaded_commentable') || v:version < 704
	finish
endif

let g:loaded_commentable = 1
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
"| s:Reformat(setrepeat) range                                           {{{ |
"|===========================================================================|
function! s:Reformat(setrepeat) range
	let l:toreformat = []
	let l:primed = 1
	for l:lineno in range(a:firstline, a:lastline)
		if commentable#IsCommentBlock(l:lineno)
			if l:primed
				call insert(l:toreformat, l:lineno)
			endif
			let l:primed = 0
		else
			let l:primed = 1
		endif
	endfor

	"|===============================================|
	"| Now we have a list of the start of every      |
	"| comment block in range, in reverse order.     |
	"| Work through and reformat them.               |
	"|===============================================|
	for l:lineno in l:toreformat
		call commentable#Reformat(l:lineno)
	endfor

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
"| s:CreateBlock(setrepeat) range                                        {{{ |
"|===========================================================================|
function! s:CreateBlock(setrepeat) range
	execute a:firstline . ',' . a:lastline 'call commentable#CreateBlock()'

	if a:setrepeat == 1
		silent! call repeat#set("\<Plug>(CommentableCreate)")
	endif
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
"| Commands (exposed to user)                                            {{{ |
"|===========================================================================|
command -nargs=0 -range CommentableReformat <line1>,<line2>call <SID>Reformat(0)
nnoremap <silent><unique> <Plug>(CommentableReformat)
	\ :<c-u>call <SID>Reformat(1)<CR>

command -nargs=0 -range CommentableCreate <line1>,<line2>call <SID>CreateBlock(0)
nnoremap <silent><unique> <Plug>(CommentableCreate)
	\ :<c-u>call <SID>CreateBlock(1)<CR>
xnoremap <silent><unique> <Plug>(CommentableCreate)
	\ :<c-u>'<,'>call <SID> CreateBlock(1)<CR>

command -nargs=0 CommentableSetDefaultStyle
	\ let g:CommentableBlockStyle = ['#', '', '']
	\ let g:CommentableBlockWidth = 80
	\ let g:CommentableParaBefore = ['\m^[+-\*o]']
	\ let g:CommentableParaAfter  = ['\m:$']
	\ let g:CommentableParaBoth = [
	\   '\V' . split(&foldmarker, '\v\\@<!,')[0],
	\   '\V' . split(&foldmarker, '\v\\@<!,')[1],
	\   '\m^\s*$'
	\ ]
	\ augroup Commentable
	\   autocmd FileType python let b:CommentableBlockStyle = ['#', '-', '']
	\   autocmd FileType perl let b:CommentableBlockStyle = ['#*', '*', '*#']
	\   autocmd FileType sh let b:CommentableBlockStyle = ['#', '#', '#']
	\   autocmd FileType c let b:CommentableBlockStyle = ['/*', '*', '*/']
	\   autocmd FileType cpp let b:CommentableBlockStyle = ['/*', '*', '*/']
	\   autocmd FileType java let b:CommentableBlockStyle = ['//', '-', '//']
	\   autocmd FileType scheme let b:CommentableBlockStyle = [';;', '-', ';;']
	\   autocmd FileType vim let b:CommentableBlockStyle = ['"', '-', '']
	\   autocmd FileType make let b:CommentableBlockStyle = ['#', '-', '']
	\   autocmd FileType python let b:CommentableBlockWidth = 79
	\ augroup END
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
