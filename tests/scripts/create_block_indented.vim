"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
StartTest create_block_indented create_indented_comment

"|===========================================================================|
"| Create a comment from each case - check it works                          |
"|===========================================================================|
function s:RunCases()
	for l:case in range(1, 4)
		NextCase
		Out 'Comment from case: ' . l:case
		let g:CommentableBlockStyle = ['/*', '*', '*/']
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
