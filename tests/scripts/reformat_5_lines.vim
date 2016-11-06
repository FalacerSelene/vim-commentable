"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
StartTest reformat_5_lines 5_line_comment

"|===========================================================================|
"| Reformat a comment at each line inside it.                                |
"|===========================================================================|
function RunCase(atlineno)
	NextCase
	Out 'Reformat a comment with cursor from line ' . a:atlineno
	let g:CommentableBlockStyle = ['/*', '*', '*/']
	call append(line('$'), GetCase(1))
	let s:line = line('$') + a:atlineno - 6
	execute s:line . 'CommentableReformat'
endfunction

for s:atlineno in [0, 1, 2, 3, 4, 5, 6]
	call RunCase(s:atlineno)
endfor

EndTest
