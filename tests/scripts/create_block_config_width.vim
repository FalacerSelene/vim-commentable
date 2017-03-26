StartTest create_block_config_width create_single_comment

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
"| Set the global width variable only                                        |
"|===========================================================================|
NextCase
Out 'Case 2 - global width = 50'
NormalStyle
InputCase 1
let g:CommentableBlockWidth = 50
try
	$CommentableCreate
catch
	OutException
endtry

"|===========================================================================|
"| Set the buffer width variable only                                        |
"|===========================================================================|
NextCase
Out 'Case 3 - buffer width = 60'
NormalStyle
InputCase 1
let b:CommentableBlockWidth = 60
try
	$CommentableCreate
catch
	OutException
endtry

"|===========================================================================|
"| Set the global and buffer width - buffer width should win.                |
"|===========================================================================|
NextCase
Out 'Case 4 - global width = 70, buffer width = 30'
NormalStyle
InputCase 1
let g:CommentableBlockWidth = 70
let b:CommentableBlockWidth = 30
try
	$CommentableCreate
catch
	OutException
endtry

EndTest
