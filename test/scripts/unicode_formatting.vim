StartTest unicode_formatting unicode_comment

"|===========================================================================|
"| Reformat a comment with unicode characters.                               |
"|===========================================================================|
NextTest
Say 'Reformat a comment which include unicode characters'
NormalStyle
UseCase 1
Assertq $CommentableReformat

EndTest
