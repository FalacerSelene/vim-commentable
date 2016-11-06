"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
StartTest create_block_multiline multiline_comment

"|===========================================================================|
"| Create a comment from a single line of text                               |
"|===========================================================================|
function s:RunCases()
	for l:case in range(1, 3)
		NextCase
		Out 'Run case: ' . string(l:case)
		let g:CommentableBlockStyle = ['/*', '*', '*/']
		let l:firstline = line('$') + 1
		call append(line('$'), GetCase(l:case))
		let l:lastline = line('$')
		try
			execute l:firstline . ',' l:lastline . 'CommentableCreate'
		catch
			Out 'Caught exception!'
			call Out(v:exception)
		endtry
	endfor
endfunction

call <SID>RunCases()

EndTest
