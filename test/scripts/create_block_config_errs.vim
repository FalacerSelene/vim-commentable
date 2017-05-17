StartTest create_block_config_errs create_single_comment

"|===========================================================================|
"| Create a comment from a single line of text                               |
"|===========================================================================|
NextTest
Say 'Case 1 - default'
NormalStyle
UseCase 1
Assertq $CommentableCreate

"|===========================================================================|
"| Set the global width negative.                                            |
"|===========================================================================|
NextTest
Say 'Case 2 - global width negative'
NormalStyle
UseCase 1
let g:CommentableBlockWidth = -1
try
	$CommentableCreate
	Say 'Did not catch expected exception!'
catch
	Say 'Caught expected exception'
	call Say(v:exception)
endtry

"|===========================================================================|
"| Set the global width to a string.                                         |
"|===========================================================================|
NextTest
Say 'Case 3 - global width string'
NormalStyle
UseCase 1
let g:CommentableBlockWidth = -1
try
	$CommentableCreate
	Say 'Did not catch expected exception!'
catch
	Say 'Caught expected exception'
	call Say(v:exception)
endtry

"|===========================================================================|
"| Set the buffer width to a list.                                           |
"|===========================================================================|
NextTest
Say 'Case 4 - buffer width list'
NormalStyle
UseCase 1
let b:CommentableBlockWidth = [100]
try
	$CommentableCreate
	Say 'Did not catch expected exception!'
catch
	Say 'Caught expected exception'
	call Say(v:exception)
endtry

EndTest
