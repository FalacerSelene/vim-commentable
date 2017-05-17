StartTest create_block_config_column create_single_comment

"|===========================================================================|
"| Create a comment from a single line of text                               |
"|===========================================================================|
NextTest
Say 'Case 1 - default'
NormalStyle
UseCase 1
Assertq $CommentableCreate

"|===========================================================================|
"| Set the global column variable only                                       |
"|===========================================================================|
NextTest
Say 'Case 2 - global column = 50'
NormalStyle
UseCase 1
let g:CommentableBlockColumn = 50
Assertq $CommentableCreate

"|===========================================================================|
"| Set the buffer column variable only                                       |
"|===========================================================================|
NextTest
Say 'Case 3 - buffer column = 60'
NormalStyle
UseCase 1
let b:CommentableBlockColumn = 60
Assertq $CommentableCreate

"|===========================================================================|
"| Set the global and buffer column - buffer column should win.              |
"|===========================================================================|
NextTest
Say 'Case 4 - global column = 70, buffer column = 30'
NormalStyle
UseCase 1
let g:CommentableBlockColumn = 70
let b:CommentableBlockColumn = 30
Assertq $CommentableCreate

EndTest
