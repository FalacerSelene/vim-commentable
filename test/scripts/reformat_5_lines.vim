StartTest reformat_5_lines 5_line_comment

"|===========================================================================|
"| Reformat a comment at each line inside it.                                |
"|===========================================================================|
function s:RunCase(atlineno)
	NextTest
	Say 'Reformat a comment with cursor from line ' . a:atlineno
	NormalStyle
	UseCase 1
	Assert (b:case_firstline + a:atlineno) . 'CommentableReformat'
endfunction

for s:atlineno in [0, 1, 2, 3, 4, 5, 6]
	call <SID>RunCase(s:atlineno)
endfor

EndTest
