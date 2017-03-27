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
			NextCase
			Out 'Comment from case: ' . l:case
			let g:CommentableBlockStyle = l:block
			let g:CommentableSubStyle = l:sub
			Out 'BlockStyle: ' . string(g:CommentableBlockStyle)
			Out 'SubStyle: ' . string(g:CommentableSubStyle)

			InputCase l:case
			try
				$CommentableReformat
			catch
				OutException
			endtry
		endfor
	endfor
endfunction

call <SID>RunCases()

EndTest
