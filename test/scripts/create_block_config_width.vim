StartTest create_block_config_width create_single_comment

"|===========================================================================|
"| Create a comment from a single line of text                               |
"|===========================================================================|
NextTest
Say 'Case 1 - default'
NormalStyle
UseCase 1
Assertq $CommentableCreate

"|===========================================================================|
"| Set the global width variable only                                        |
"|===========================================================================|
NextTest
Say 'Case 2 - global width = 50'
NormalStyle
UseCase 1
let g:CommentableBlockWidth = 50
Assertq $CommentableCreate

"|===========================================================================|
"| Set the buffer width variable only                                        |
"|===========================================================================|
NextTest
Say 'Case 3 - buffer width = 60'
NormalStyle
UseCase 1
let b:CommentableBlockWidth = 60
Assertq $CommentableCreate

"|===========================================================================|
"| Set the global and buffer width - buffer width should win.                |
"|===========================================================================|
NextTest
Say 'Case 4 - global width = 70, buffer width = 30'
NormalStyle
UseCase 1
let g:CommentableBlockWidth = 70
let b:CommentableBlockWidth = 30
Assertq $CommentableCreate

EndTest
