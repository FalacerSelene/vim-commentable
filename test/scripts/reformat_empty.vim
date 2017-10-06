StartTest reformat_empty short_comment

"|===========================================================================|
"| Reformat the null (empty) block.                                          |
"|===========================================================================|
NextTest
Say 'Reformat the null (empty) block'
NormalStyle
UseCase 2
Assertq $CommentableReformat

EndTest
