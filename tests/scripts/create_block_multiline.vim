StartTest create_block_multiline multiline_comment

"|===========================================================================|
"| Create a comment from a multiple lines of text                            |
"|===========================================================================|
function s:RunCase(case)
	NextCase
	Out 'Run case: ' . string(a:case)
	NormalStyle
	InputCase a:case
	try
		execute b:case_firstline . ',' . b:case_lastline . 'CommentableCreate'
	catch
		OutException
	endtry
endfunction

for s:i in range(1, 3)
	call <SID>RunCase(s:i)
endfor

EndTest
