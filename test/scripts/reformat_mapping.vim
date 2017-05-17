StartTest reformat_mapping short_comment

"|===========================================================================|
"| Reformat a comment using the mapping.                                     |
"|===========================================================================|
NextTest
Say 'Reformat a comment using a mapping'
NormalStyle
UseCase 1
nmap (testmap) <Plug>(CommentableReformat)
call cursor('$', '1')
Assertq normal (testmap)

"|===========================================================================|
"| Reformat a comment using the default mapping.                             |
"|===========================================================================|
NextTest
Say 'Reformat a comment using the default mapping'
NormalStyle
UseCase 1
CommentableSetDefaultBindings
call cursor(line('$'), '1')
Assertq normal gcq

EndTest
