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
"| Set the global width variable only                                        |
"|===========================================================================|
NextCase
Out 'Case 2 - global width = 50'
let g:CommentableBlockStyle = ['/*', '*', '*/']
let g:CommentableBlockWidth = 50
let s:lines = GetCase(1)
call append(line('$'), s:lines)
try
	execute line('$') . 'CommentableCreate'
catch
	Out 'Caught exception!'
	call Out(v:exception)
endtry

"|===========================================================================|
"| Set the buffer width variable only                                        |
"|===========================================================================|
NextCase
Out 'Case 3 - buffer width = 60'
let g:CommentableBlockStyle = ['/*', '*', '*/']
let b:CommentableBlockWidth = 60
let s:lines = GetCase(1)
call append(line('$'), s:lines)
try
	execute line('$') . 'CommentableCreate'
catch
	Out 'Caught exception!'
	call Out(v:exception)
endtry

"|===========================================================================|
"| Set the global and buffer width - buffer width should win.                |
"|===========================================================================|
NextCase
Out 'Case 4 - global width = 70, buffer width = 30'
let g:CommentableBlockStyle = ['/*', '*', '*/']
let g:CommentableBlockWidth = 70
let b:CommentableBlockWidth = 30
let s:lines = GetCase(1)
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
saveas output/create_block_config_width.out
quitall!
