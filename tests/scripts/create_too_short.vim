StartTest create_too_short create_single_comment

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
		NormalStyle
		InputCase 1
		execute 'let ' . l:var . ' = 10'
		try
			$CommentableCreate
		catch
			OutException
		endtry
	endfor
endfunction

call <SID>RunCases()

EndTest
