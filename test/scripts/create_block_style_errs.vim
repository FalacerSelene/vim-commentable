StartTest create_block_style_errs create_single_comment

function! s:DoCase(text, style, expect_fail)
	NextTest
	Say a:text
	let g:CommentableBlockStyle = a:style
	UseCase 1
	if !a:expect_fail
		Assertq $CommentableCreate
	else
		try
			$CommentableCreate
			Say 'Did not catch expected exception!'
		catch
			Say 'Caught expected exception!'
			Say v:exception
		endtry
	endif
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

call <SID>DoCase('Case 8 - empty regex part',
 \               [['/*', ''], '*', '*/'],
 \               0)

call <SID>DoCase('Case 9 - no regex part',
 \               [['/*'], '*', '*/'],
 \               0)

call <SID>DoCase('Case 10 - too much content in first element',
 \               [['/*', '/*', '/*'], '*', '*/'],
 \               1)

EndTest
