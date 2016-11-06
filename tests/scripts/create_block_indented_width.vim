"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
StartTest create_block_indented_width create_indented_comment

"|===========================================================================|
"| Create a comment from each case - check the width applies                 |
"|===========================================================================|
function s:RunCases()
	for l:case in range(1, 4)
		NextCase
		Out 'Comment from case: ' . l:case
		let g:CommentableBlockStyle = ['/*', '*', '*/']
		let g:CommentableBlockWidth = 50
		let g:CommentableSubWidth = 60
		if l:case ==# 3
			let b:CommentableBlockWidth = 80
		elseif l:case ==# 4
			let b:CommentableSubWidth = 20
		endif
		call append(line('$'), GetCase(l:case))
		try
			execute line('$') . 'CommentableCreate'
		catch
			Out 'Caught exception!'
			call Out(v:exception)
		endtry
	endfor
endfunction

call <SID>RunCases()

EndTest
