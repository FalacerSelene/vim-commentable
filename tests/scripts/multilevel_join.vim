StartTest multilevel_join multilevel_join

NextCase
NormalStyle
InputCase 1
try
	execute b:case_firstline . ',' . b:case_lastline . 'CommentableCreate'
catch
	OutException
endtry

EndTest
