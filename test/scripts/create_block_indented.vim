StartTest create_block_indented create_indented_comment

"|===========================================================================|
"| Create a comment from each case - check it works                          |
"|===========================================================================|
function s:RunCase(case)
	NextCase
	Out 'Comment from case: ' . a:case
	NormalStyle
	InputCase a:case
	try
		$CommentableCreate
	catch
		OutException
	endtry
endfunction

for s:case in range(1, 4)
	call <SID>RunCase(s:case)
endfor

EndTest
