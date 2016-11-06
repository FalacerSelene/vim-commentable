"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
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
			call Out('BlockStyle: ' . string(g:CommentableBlockStyle))
			call Out('SubStyle: ' . string(g:CommentableSubStyle))

			call append(line('$'), GetCase(l:case))
				execute line('$') . 'CommentableReformat'
			try
				execute line('$') . 'CommentableReformat'
			catch
				Out 'Caught exception!'
				call Out(v:exception)
			endtry
		endfor
	endfor
endfunction

call <SID>RunCases()

EndTest
