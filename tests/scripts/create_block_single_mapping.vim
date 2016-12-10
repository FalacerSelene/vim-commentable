"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
StartTest create_block_single_mapping create_single_comment

"|===========================================================================|
"| Create a comment from a single line of text                               |
"|===========================================================================|
NextCase
let g:CommentableBlockStyle = ['/*', '*', '*/']
call append(line('$'), GetCase(1))
nmap (testmap) <Plug>(CommentableCreate)

try
	call cursor(line('$'), '1')
	normal (testmap)
catch
	Out 'Caught exception!'
	call Out(v:exception)
endtry

"|===========================================================================|
"| Create comment using the default mapping                                  |
"|===========================================================================|
NextCase
let g:CommentableBlockStyle = ['/*', '*', '*/']
call append(line('$'), GetCase(1))
CommentableSetDefaultBindings

try
	call cursor(line('$'), '1')
	normal gcc
catch
	Out 'Caught exception!'
	call Out(v:exception)
endtry

EndTest
