"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/create_indented_comment.in

"|===========================================================================|
"| Create a comment from a indented text                                     |
"|===========================================================================|
NextCase
Out 'Comment from 2 space indented text'
let g:CommentableBlockStyle = ['/*', '*', '*/']
let s:lines = GetCase(1)
call append(line('$'), s:lines)
try
	execute line('$') . 'CommentableCreate'
catch
	Out 'Caught exception!'
	call Out(v:exception)
endtry

"|===========================================================================|
"| Create a comment from 4 space indented text                               |
"|===========================================================================|
NextCase
Out 'Comment from 4 space indented text'
let g:CommentableBlockStyle = ['/*', '*', '*/']
let s:lines = GetCase(2)
call append(line('$'), s:lines)
try
	execute line('$') . 'CommentableCreate'
catch
	Out 'Caught exception!'
	call Out(v:exception)
endtry

"|===========================================================================|
"| Create a comment from tab indented text                                   |
"|===========================================================================|
NextCase
Out 'Comment from tab indented text'
let g:CommentableBlockStyle = ['/*', '*', '*/']
let s:lines = GetCase(3)
call append(line('$'), s:lines)
try
	execute line('$') . 'CommentableCreate'
catch
	Out 'Caught exception!'
	call Out(v:exception)
endtry

"|===========================================================================|
"| Save and conclude                                                         |
"|===========================================================================|
NextCase
Out '-- End of Test --'
saveas output/create_block_indented.out
quitall!
