StartTest create_block_config_style create_single_comment

function! s:DoCase(text, style)
	NextCase
	Out a:text
	InputCase 1
	let g:CommentableBlockStyle = a:style
	try
		$CommentableCreate
	catch
		OutException
	endtry
endfunction

call <SID>DoCase('Case 1 - default',
 \               ['/*', '*', '*/'])
call <SID>DoCase('Case 2 - perlish style',
 \               ['#=', '=', '=#'])
call <SID>DoCase('Case 3 - vimmish style',
 \               ['"|', '=', '|'])
call <SID>DoCase('Case 4 - style with no final part',
 \               ['((', '-', ''])
call <SID>DoCase('Case 5 - style with no medial part',
 \               [';;', '', ''])
call <SID>DoCase('Case 6 - style with initial and medial only',
 \               [';;', '', ';;'])

EndTest
