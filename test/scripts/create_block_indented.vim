StartTest create_block_indented create_indented_comment

"|===========================================================================|
"| Create a comment from each case - check it works                          |
"|===========================================================================|
function s:RunCase(case)
	NextTest
	Say 'Comment from case: ' . a:case
	NormalStyle
	UseCase a:case
	Assertq $CommentableCreate
endfunction

for s:case in range(1, 4)
	call <SID>RunCase(s:case)
endfor

EndTest
