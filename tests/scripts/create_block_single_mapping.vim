"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/create_single_comment.in

"|===========================================================================|
"| Create a comment from a single line of text                               |
"|===========================================================================|
NextCase
let g:CommentableBlockStyle = ['/*', '*', '*/']
let s:lines = GetCase(1)
call append(line('$'), s:lines)

nmap (testmap) <Plug>(CommentableCreate)
try
	call cursor(line('$'), '1')
	normal (testmap)
catch
	Out 'Caught exception!'
	call Out(v:exception)
endtry

"|===========================================================================|
"| Save and conclude                                                         |
"|===========================================================================|
NextCase
Out '-- End of Test --'
saveas output/create_block_single_mapping.out
quitall!
