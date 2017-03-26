StartTest create_block_indented_column create_indented_comment

"|===========================================================================|
"| Create a comment from each case - check the column applies                |
"|===========================================================================|
function s:RunCase(case)
	NextCase
	Out 'Comment from case: ' . a:case
	NormalStyle
	InputCase a:case
	let g:CommentableBlockColumn = 50
	let g:CommentableSubColumn = 60
	if a:case ==# 3
		let b:CommentableBlockColumn = 80
	elseif a:case ==# 4
		let b:CommentableSubColumn = 30
	endif
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
