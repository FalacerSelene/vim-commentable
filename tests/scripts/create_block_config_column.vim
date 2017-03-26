StartTest create_block_config_column create_single_comment

"|===========================================================================|
"| Create a comment from a single line of text                               |
"|===========================================================================|
NextCase
Out 'Case 1 - default'
NormalStyle
InputCase 1
try
	$CommentableCreate
catch
	OutException
endtry

"|===========================================================================|
"| Set the global column variable only                                       |
"|===========================================================================|
NextCase
Out 'Case 2 - global column = 50'
NormalStyle
InputCase 1
let g:CommentableBlockColumn = 50
try
	$CommentableCreate
catch
	OutException
endtry

"|===========================================================================|
"| Set the buffer column variable only                                       |
"|===========================================================================|
NextCase
Out 'Case 3 - buffer column = 60'
NormalStyle
InputCase 1
let b:CommentableBlockColumn = 60
try
	$CommentableCreate
catch
	OutException
endtry

"|===========================================================================|
"| Set the global and buffer column - buffer column should win.              |
"|===========================================================================|
NextCase
Out 'Case 4 - global column = 70, buffer column = 30'
NormalStyle
InputCase 1
let g:CommentableBlockColumn = 70
let b:CommentableBlockColumn = 30
try
	$CommentableCreate
catch
	OutException
endtry

EndTest
