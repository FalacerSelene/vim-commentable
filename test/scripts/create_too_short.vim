StartTest create_too_short create_single_comment

"|===========================================================================|
"| Create a comment from a single line of text, with width/column too short. |
"|===========================================================================|
function s:RunCases()
	for [l:text, l:var] in [
	 \   ['width', 'g:CommentableBlockWidth'],
	 \   ['column', 'g:CommentableBlockColumn'],
	 \ ]
		NextTest
		Say 'Create block with ' . l:text . ' set too short'
		NormalStyle
		UseCase 1
		execute 'let' l:var '=' 10
		Assertq $CommentableCreate
	endfor
endfunction

call <SID>RunCases()

EndTest
