"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
StartTest create_block_many many_comments

function s:Case(case_number)
	NextCase
	let g:CommentableBlockStyle = ['/*', '*', '*/']
	let l:first_line = line('$') + 1
	call append(line('$'), GetCase(a:case_number))
	try
		execute l:first_line . ',' . line('$') . 'CommentableCreate'
	catch
		Out 'Caught exception!'
		call Out(v:exception)
	endtry
endfunction

for s:i in range(1, 2)
	call <SID>Case(s:i)
endfor

EndTest
