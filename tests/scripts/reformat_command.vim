"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
StartTest reformat_command short_comment

"|===========================================================================|
"| Reformat a comment using the command.                                     |
"|===========================================================================|
NextCase
Out 'Reformat a comment using a command'
let g:CommentableBlockStyle = ['/*', '*', '*/']
call append(line('$'), GetCase(1))
try
	execute line('$') . 'CommentableReformat'
catch
	Out 'Caught exception!'
	call Out(v:exception)
endtry

EndTest
