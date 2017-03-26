StartTest create_block_indented_style create_indented_comment

"|===========================================================================|
"| Create a comment from each case - check the style applies                 |
"|===========================================================================|
function s:RunCase(case)
	NextCase
	Out 'Comment from case: ' . a:case
	NormalStyle
	InputCase a:case
	let g:CommentableSubStyle = ['#*', '*', '*#']
	if a:case ==# 3
		let b:CommentableBlockStyle = ['#=','=','=|']
	elseif a:case ==# 4
		let b:CommentableSubStyle = [';;','-','|']
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
