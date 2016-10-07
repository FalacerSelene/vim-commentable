"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/create_indented_comment.in

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

"|===========================================================================|
"| Save and conclude                                                         |
"|===========================================================================|
NextCase
Out '-- End of Test --'
saveas output/create_block_indented.out
quitall!
