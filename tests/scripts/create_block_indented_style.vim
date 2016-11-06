"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
StartTest create_block_indented_style create_indented_comment

"|===========================================================================|
"| Create a comment from each case - check the style applies                 |
"|===========================================================================|
function s:RunCases()
	for l:case in range(1, 4)
		NextCase
		Out 'Comment from case: ' . l:case
		let g:CommentableBlockStyle = ['/*', '*', '*/']
		let g:CommentableSubStyle = ['#*', '*', '*#']
		if l:case ==# 3
			let b:CommentableBlockStyle = ['#=','=','=|']
		elseif l:case ==# 4
			let b:CommentableSubStyle = [';;','-','|']
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
