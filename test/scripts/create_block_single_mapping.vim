StartTest create_block_single_mapping create_single_comment

"|===========================================================================|
"| Create a comment from a single line of text                               |
"|===========================================================================|
NextTest
NormalStyle
UseCase 1
nmap (testmap) <Plug>(CommentableCreate)
call cursor('$', '1')
Assertq normal (testmap)

"|===========================================================================|
"| Create comment using the default mapping                                  |
"|===========================================================================|
NextTest
NormalStyle
UseCase 1
CommentableSetDefaultBindings
call cursor('$', '1')
Assertq normal gcc

EndTest
