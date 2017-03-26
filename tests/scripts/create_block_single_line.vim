StartTest create_block_single_line create_single_comment

"|===========================================================================|
"| Create a comment from a single line of text                               |
"|===========================================================================|
NextCase
NormalStyle
InputCase 1
try
	$CommentableCreate
catch
	OutException
endtry

EndTest
