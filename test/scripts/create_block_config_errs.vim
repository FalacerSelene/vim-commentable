StartTest create_block_config_errs create_single_comment

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
"| Set the global width negative.                                            |
"|===========================================================================|
NextCase
Out 'Case 2 - global width negative'
NormalStyle
InputCase 1
let g:CommentableBlockWidth = -1
try
	$CommentableCreate
	Out 'Did not catch expected exception!'
catch
	Out 'Caught expected exception'
	call Out(v:exception)
endtry

"|===========================================================================|
"| Set the global width to a string.                                         |
"|===========================================================================|
NextCase
Out 'Case 3 - global width string'
NormalStyle
InputCase 1
let g:CommentableBlockWidth = -1
try
	$CommentableCreate
	Out 'Did not catch expected exception!'
catch
	Out 'Caught expected exception'
	call Out(v:exception)
endtry

"|===========================================================================|
"| Set the buffer width to a list.                                           |
"|===========================================================================|
NextCase
Out 'Case 4 - buffer width list'
NormalStyle
InputCase 1
let b:CommentableBlockWidth = [100]
try
	$CommentableCreate
	Out 'Did not catch expected exception!'
catch
	Out 'Caught expected exception'
	call Out(v:exception)
endtry

EndTest
