StartTest create_block_multiline multiline_comment

"|===========================================================================|
"| Create a comment from a multiple lines of text                            |
"|===========================================================================|
function s:RunCase(case)
	NextTest
	Say 'Run case: ' . string(a:case)
	NormalStyle
	UseCase a:case
	Assert b:case_firstline . ',' . b:case_lastline . 'CommentableCreate'
endfunction

for s:i in range(1, 3)
	call <SID>RunCase(s:i)
endfor

EndTest
