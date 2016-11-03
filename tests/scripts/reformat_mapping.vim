"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/short_comment.in

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

EndTest reformat_mapping
