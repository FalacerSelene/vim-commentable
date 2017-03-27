StartTest create_block_indented_width create_indented_comment

"|===========================================================================|
"| Create a comment from each case - check the width applies                 |
"|===========================================================================|
function s:RunCase(case)
	NextCase
	Out 'Comment from case: ' . a:case
	NormalStyle
	InputCase a:case
	let g:CommentableBlockWidth = 50
	let g:CommentableSubWidth = 60
	if a:case ==# 3
		let b:CommentableBlockWidth = 80
	elseif a:case ==# 4
		let b:CommentableSubWidth = 20
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
