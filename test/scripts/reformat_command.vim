StartTest reformat_command short_comment

"|===========================================================================|
"| Reformat a comment using the command.                                     |
"|===========================================================================|
NextCase
Out 'Reformat a comment using a command'
NormalStyle
InputCase 1
try
	$CommentableReformat
catch
	OutException
endtry

EndTest
