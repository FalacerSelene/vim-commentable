StartTest reformat_mapping short_comment

"|===========================================================================|
"| Reformat a comment using the mapping.                                     |
"|===========================================================================|
NextCase
Out 'Reformat a comment using a mapping'
NormalStyle
InputCase 1
nmap (testmap) <Plug>(CommentableReformat)

try
	call cursor(line('$'), '1')
	normal (testmap)
catch
	OutException
endtry

"|===========================================================================|
"| Reformat a comment using the default mapping.                             |
"|===========================================================================|
NextCase
Out 'Reformat a comment using the default mapping'
NormalStyle
InputCase 1
CommentableSetDefaultBindings

try
	call cursor(line('$'), '1')
	normal gcq
catch
	OutException
endtry

EndTest
