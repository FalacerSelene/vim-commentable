"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/create_single_comment.in

function! s:DoCase(text, style, expect_fail)
	NextCase
	call Out(a:text)
	let g:CommentableBlockStyle = a:style
	let l:lines = GetCase(1)
	call append(line('$'), l:lines)
	try
		execute line('$') . 'CommentableCreate'
		if a:expect_fail
			Out 'Did not catch expected exception!'
		endif
	catch
		call Out('Caught ' . (a:expect_fail ? 'expected ' : '') . 'exception!')
		call Out(v:exception)
	endtry
endfunction

call <SID>DoCase('Case 1 - default',
 \               ['/*', '*', '*/'],
 \               0)

call <SID>DoCase('Case 2 - no initial part',
 \               ['', '*', '*/'],
 \               1)

call <SID>DoCase('Case 3 - list too short',
 \               ['/*', '*'],
 \               1)

call <SID>DoCase('Case 4 - not a list',
 \               '/***/',
 \               1)

call <SID>DoCase('Case 5 - leading whitespace in first',
 \               [' /*', '', '*/'],
 \               1)

call <SID>DoCase('Case 6 - trailing whitespace in last',
 \               ['/*', '', '*/ '],
 \               1)

call <SID>DoCase('Case 7 - set textlead',
 \               ['/*', '*', '*/', '-'],
 \               0)

EndTest create_block_style_errs
