StartTest reformat_indented_style indented_comments

"|===========================================================================|
"| Create a comment from each case - check the style applies                 |
"|===========================================================================|
function s:RunCases()
	let l:c = ['/*','*','*/']
	let l:p = ['#*','*','*#']

	for l:case in [1, 5, 6, 7]
		for [l:block, l:sub] in [
		 \ [l:c, l:c],
		 \ [l:c, l:p],
		 \ [l:p, l:c],
		 \ [l:p, l:p],
		 \ ]
			NextTest
			Say 'Comment from case: ' . l:case
			let g:CommentableBlockStyle = l:block
			let g:CommentableSubStyle = l:sub
			Say 'BlockStyle: ' . string(g:CommentableBlockStyle)
			Say 'SubStyle: ' . string(g:CommentableSubStyle)

			UseCase l:case
			Assertq $CommentableReformat
		endfor
	endfor
endfunction

call <SID>RunCases()

EndTest
