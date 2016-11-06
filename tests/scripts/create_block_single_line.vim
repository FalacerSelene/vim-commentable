"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
StartTest create_block_single_line create_single_comment

"|===========================================================================|
"| Create a comment from a single line of text                               |
"|===========================================================================|
NextCase
let g:CommentableBlockStyle = ['/*', '*', '*/']
call append(line('$'), GetCase(1))
try
	execute line('$') . 'CommentableCreate'
catch
	Out 'Caught exception!'
	call Out(v:exception)
endtry

EndTest
