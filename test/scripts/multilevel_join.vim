StartTest multilevel_join multilevel_join

"|===========================================================================|
"| Use Create to join blocks together                                        |
"|===========================================================================|
NextCase
NormalStyle
InputCase 1
try
	execute b:case_firstline . ',' . b:case_lastline . 'CommentableCreate'
catch
	OutException
endtry

"|===========================================================================|
"| Check that joining from medial lines works the same                       |
"|===========================================================================|
NextCase
NormalStyle
InputCase 1
try
	let s:first = b:case_firstline + 1
	let s:last = b:case_firstline + 6
	execute s:first . ',' . s:last . 'CommentableCreate'
catch
	OutException
endtry

EndTest
