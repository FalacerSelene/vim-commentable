"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/create_single_comment.in

"|===========================================================================|
"| Create a comment from a single line of text                               |
"|===========================================================================|
NextCase
Out 'Case 1 - default'
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
"| Set the global width negative.                                            |
"|===========================================================================|
NextCase
Out 'Case 2 - global width negative'
let g:CommentableBlockStyle = ['/*', '*', '*/']
let g:CommentableBlockWidth = -1
let s:lines = GetCase(1)
call append(line('$'), s:lines)
try
	execute line('$') . 'CommentableCreate'
	Out 'Did not catch expected exception!'
catch
	Out 'Caught expected exception'
	call Out(v:exception)
endtry

"|===========================================================================|
"| Set the global width to a string.                                         |
"|===========================================================================|
NextCase
Out 'Case 3 - global width string'
let g:CommentableBlockStyle = ['/*', '*', '*/']
let g:CommentableBlockWidth = -1
let s:lines = GetCase(1)
call append(line('$'), s:lines)
try
	execute line('$') . 'CommentableCreate'
	Out 'Did not catch expected exception!'
catch
	Out 'Caught expected exception'
	call Out(v:exception)
endtry

"|===========================================================================|
"| Set the buffer width to a list.                                           |
"|===========================================================================|
NextCase
Out 'Case 4 - buffer width list'
let g:CommentableBlockStyle = ['/*', '*', '*/']
let b:CommentableBlockWidth = [100]
let s:lines = GetCase(1)
call append(line('$'), s:lines)
try
	execute line('$') . 'CommentableCreate'
	Out 'Did not catch expected exception!'
catch
	Out 'Caught expected exception'
	call Out(v:exception)
endtry

"|===========================================================================|
"| Save and conclude                                                         |
"|===========================================================================|
NextCase
Out '-- End of Test --'
saveas output/create_block_config_errs.out
quitall!
