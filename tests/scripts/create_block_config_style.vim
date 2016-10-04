"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/create_single_comment.in

function! s:DoCase(text, style)
	NextCase
	call Out(a:text)
	let g:CommentableBlockStyle = a:style
	let l:lines = GetCase(1)
	call append(line('$'), l:lines)
	try
		execute line('$') . 'CommentableCreate'
	catch
		Out 'Caught exception!'
		call Out(v:exception)
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

"|===========================================================================|
"| Save and conclude                                                         |
"|===========================================================================|
NextCase
Out '-- End of Test --'
saveas output/create_block_config_style.out
quitall!