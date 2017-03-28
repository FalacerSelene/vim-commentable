StartTest multilevel_reformat multilevel_comment

"|===========================================================================|
"| Reformat multilevel blocks                                                |
"|===========================================================================|
NextCase
NormalStyle
InputCase 1
try
	execute b:case_firstline . ',' . b:case_lastline . 'CommentableReformat'
catch
	OutException
endtry

"|===========================================================================|
"| Check that reformat from medial lines works the same                      |
"|===========================================================================|
NextCase
NormalStyle
InputCase 1
try
	let s:first = b:case_firstline + 1
	let s:last = b:case_firstline + 6
	execute s:first . ',' . s:last . 'CommentableReformat'
catch
	OutException
endtry

EndTest
