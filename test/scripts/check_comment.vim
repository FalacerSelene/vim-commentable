StartTest check_comment many_comments

"|===========================================================================|
"| Check that we can tell what is and isn't a comment                        |
"|===========================================================================|
NextTest
Say 'Check we can identify comments'
NormalStyle
UseCase 2

let s:num_checks = b:case_lastline - b:case_firstline + 1
call cursor(b:case_firstline, 1)

while s:num_checks > 0
	let s:this_is_comment = commentable#IsCommentBlock('.')
	if commentable#IsCommentBlock('.')
		call append('.', '^^^   IS A COMMENT   ^^^')
	else
		call append('.', '^^^ IS NOT A COMMENT ^^^')
	endif
	normal! jj
	let s:num_checks -= 1
endwhile

EndTest
