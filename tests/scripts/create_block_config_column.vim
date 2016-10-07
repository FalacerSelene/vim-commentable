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
"| Set the global column variable only                                       |
"|===========================================================================|
NextCase
Out 'Case 2 - global column = 50'
let g:CommentableBlockStyle = ['/*', '*', '*/']
let g:CommentableBlockColumn = 50
let s:lines = GetCase(1)
call append(line('$'), s:lines)
try
	execute line('$') . 'CommentableCreate'
catch
	Out 'Caught exception!'
	call Out(v:exception)
endtry

"|===========================================================================|
"| Set the buffer column variable only                                       |
"|===========================================================================|
NextCase
Out 'Case 3 - buffer column = 60'
let g:CommentableBlockStyle = ['/*', '*', '*/']
let b:CommentableBlockColumn = 60
let s:lines = GetCase(1)
call append(line('$'), s:lines)
try
	execute line('$') . 'CommentableCreate'
catch
	Out 'Caught exception!'
	call Out(v:exception)
endtry

"|===========================================================================|
"| Set the global and buffer column - buffer column should win.              |
"|===========================================================================|
NextCase
Out 'Case 4 - global column = 70, buffer column = 30'
let g:CommentableBlockStyle = ['/*', '*', '*/']
let g:CommentableBlockColumn = 70
let b:CommentableBlockColumn = 30
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
saveas output/create_block_config_column.out
quitall!
