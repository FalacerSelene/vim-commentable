"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/reformat_indented_comment.in

"|===========================================================================|
"| Reformat the comment from each case and check the column applies          |
"|===========================================================================|
function s:RunCases()
	for l:case in range(1, 4)
		for l:setting in range(3)
			NextCase
			Out 'Comment case ' . l:case
			let g:CommentableBlockStyle = ['/*', '*', '*/']
			let g:CommentableBlockColumn = 50
			let g:CommentableSubColumn = 60
			if l:setting ==# 1
				let g:CommentableBlockColumn = 80
			elseif l:setting ==# 2
				let g:CommentableSubColumn = 30
			endif

			Out ('Setting ' . l:setting .
			 \   ', block column ' . g:CommentableBlockColumn .
			 \   ', sub column ' . g:CommentableSubColumn)
			call append(line('$'), GetCase(l:case))
			try
				execute '' . (line('$') - 1) . 'CommentableReformat'
			catch
				Out 'Caught exception!'
				call Out(v:exception)
			endtry
		endfor
	endfor
endfunction

call <SID>RunCases()

EndTest reformat_indented_column
