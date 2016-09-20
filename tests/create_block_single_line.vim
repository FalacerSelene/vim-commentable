"|=============================================================================|
"| Begin                                                                       |
"|=============================================================================|
source utils.vim
edit create_block_single_line.in

"|===========================================================================|
"| Create a comment from a single line of text                               |
"|===========================================================================|
NextCase
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
"| Save and conclude                                                         |
"|===========================================================================|
NextCase
Out '-- End of Test --'
saveas create_block_single_line.out
quit!
