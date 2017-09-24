StartTest redo_ends nearly_there

"|===========================================================================|
"| Reformat a block which only has black line ends out of place              |
"|===========================================================================|
NextTest
Say 'Reformat and fix blank line ends'
NormalStyle
UseCase 1
Assertq $CommentableReformat

EndTest
