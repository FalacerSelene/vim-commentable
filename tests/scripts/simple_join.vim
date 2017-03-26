StartTest simple_join many_comments

function s:RunCase(case)
	NextCase
	NormalStyle
	InputCase a:case
	try
		execute b:case_firstline . ',' . b:case_lastline . 'CommentableCreate'
	catch
		OutException
	endtry
endfunction

for s:i in range(1, 2)
	call <SID>RunCase(s:i)
endfor

EndTest
