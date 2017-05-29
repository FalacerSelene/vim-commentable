StartTest create_block_indented_style create_indented_comment

"|===========================================================================|
"| Create a comment from each case - check the style applies                 |
"|===========================================================================|
function s:RunCase(case)
	NextTest
	Say 'Comment from case: ' . a:case
	NormalStyle
	UseCase a:case
	let g:CommentableSubStyle = ['#*', '*', '*#']
	if a:case ==# 3
		let b:CommentableBlockStyle = ['#=','=','=|']
	elseif a:case ==# 4
		let b:CommentableSubStyle = [';;','-','|']
	endif
	Assertq $CommentableCreate
endfunction

for s:case in range(1, 4)
	call <SID>RunCase(s:case)
endfor

EndTest
