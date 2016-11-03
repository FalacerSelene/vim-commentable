"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/create_single_comment.in

"|===========================================================================|
"| Create a comment from a single line of text, with width/column too short. |
"|===========================================================================|
function s:RunCases()
	for [l:text, l:var] in [
	 \   ['width', 'g:CommentableBlockWidth'],
	 \   ['column', 'g:CommentableBlockColumn'],
	 \ ]
		NextCase
		Out 'Create block with ' . l:text . ' set too short'
		let g:CommentableBlockStyle = ['/*', '*', '*/']
		execute 'let ' . l:var . ' = 10'
		call append(line('$'), GetCase(1))
		try
			execute line('$') . 'CommentableCreate'
		catch
			Out 'Caught exception!'
			call Out(v:exception)
		endtry
	endfor
endfunction

call <SID>RunCases()

EndTest create_too_short
