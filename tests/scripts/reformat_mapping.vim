"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
StartTest reformat_mapping short_comment

"|===========================================================================|
"| Reformat a comment using the mapping.                                     |
"|===========================================================================|
NextCase
Out 'Reformat a comment using a mapping'
let g:CommentableBlockStyle = ['/*', '*', '*/']
call append(line('$'), GetCase(1))
nmap (testmap) <Plug>(CommentableReformat)

try
	call cursor(line('$'), '1')
	normal (testmap)
catch
	Out 'Caught exception!'
	call Out(v:exception)
endtry

"|===========================================================================|
"| Reformat a comment using the default mapping.                             |
"|===========================================================================|
NextCase
Out 'Reformat a comment using the default mapping'
let g:CommentableBlockStyle = ['/*', '*', '*/']
call append(line('$'), GetCase(1))
CommentableSetDefaultBindings

try
	call cursor(line('$'), '1')
	normal gcq
catch
	Out 'Caught exception!'
	call Out(v:exception)
endtry

EndTest
