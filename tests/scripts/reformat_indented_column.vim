StartTest reformat_indented_column reformat_indented_comment

"|===========================================================================|
"| Reformat the comment from each case and check the column applies          |
"|===========================================================================|
function s:RunCase(case, setting)
	NextCase
	Out 'Comment case ' . a:case
	NormalStyle
	let g:CommentableBlockColumn = 50
	let g:CommentableSubColumn = 60
	if a:setting ==# 1
		let g:CommentableBlockColumn = 80
	elseif a:setting ==# 2
		let g:CommentableSubColumn = 30
	endif

	Out ('Setting ' . a:setting .
	 \   ', block column ' . g:CommentableBlockColumn .
	 \   ', sub column ' . g:CommentableSubColumn)
	InputCase a:case
	try
		execute ((b:case_lastline - 1) . 'CommentableReformat')
	catch
		OutException
	endtry
endfunction

for s:i in range(1, 4)
	for s:j in range(3)
		call <SID>RunCase(s:i, s:j)
	endfor
endfor

EndTest
