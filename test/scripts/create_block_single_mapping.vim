StartTest create_block_single_mapping create_single_comment

"|===========================================================================|
"| Create a comment from a single line of text                               |
"|===========================================================================|
NextCase
NormalStyle
InputCase 1
nmap (testmap) <Plug>(CommentableCreate)

try
	call cursor(line('$'), '1')
	normal (testmap)
catch
	OutException
endtry

"|===========================================================================|
"| Create comment using the default mapping                                  |
"|===========================================================================|
NextCase
NormalStyle
InputCase 1
CommentableSetDefaultBindings

try
	call cursor(line('$'), '1')
	normal gcc
catch
	OutException
endtry

EndTest
