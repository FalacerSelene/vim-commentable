StartTest reformat_styles comment_styles

"|===========================================================================|
"| Reformat a C-style comment with both styles set.                          |
"|===========================================================================|
NextTest
Say 'Reformat C-style comments with both styles set'

Say 'C style set'
NormalStyle
UseCase 1
Assertq $CommentableReformat

Say 'Lua style set'
let g:CommentableBlockStyle = ['--[', '=', ']--']
UseCase 1
Assertq $CommentableReformat

"|===========================================================================|
"| Reformat a Lua-style comment with both styles set.                        |
"|===========================================================================|
NextTest
Say 'Reformat Lua-style comments with both styles set'

Say 'C style set'
NormalStyle
UseCase 2
Assertq $CommentableReformat

Say 'Lua style set'
let g:CommentableBlockStyle = ['--[', '=', ']--']
UseCase 2
Assertq $CommentableReformat

"|===========================================================================|
"| Reformat a comment with only a leader.                                    |
"|===========================================================================|
NextTest
Say 'Reformat a comment with only a leader'

Say 'Normal C-style'
NormalStyle
UseCase 3
Assertq $CommentableReformat

Say 'C style with no final'
let g:CommentableBlockStyle = ['/*', '*', '']
UseCase 3
Assertq $CommentableReformat

Say 'C style with no medial'
let g:CommentableBlockStyle = ['/*', '', '*/']
UseCase 3
Assertq $CommentableReformat

Say 'C style with no medial or final'
let g:CommentableBlockStyle = ['/*', '', '']
UseCase 3
Assertq $CommentableReformat

"|===========================================================================|
"| Reformat a comment with only a final.                                     |
"|===========================================================================|
NextTest
Say 'Reformat a comment with only a final'

Say 'Normal C-style'
NormalStyle
UseCase 4
Assertq $CommentableReformat

Say 'C style with no final'
let g:CommentableBlockStyle = ['/*', '*', '']
UseCase 4
Assertq $CommentableReformat

Say 'C style with no medial'
let g:CommentableBlockStyle = ['/*', '', '*/']
UseCase 4
Assertq $CommentableReformat

Say 'C style with no medial or final'
let g:CommentableBlockStyle = ['/*', '', '']
UseCase 4
Assertq $CommentableReformat

"|===========================================================================|
"| Reformat a multiline comment down to one line.                            |
"|===========================================================================|
NextTest
Say 'Reformat a multiline comment down to one line'
NormalStyle
UseCase 5
Assertq $CommentableReformat

"|===========================================================================|
"| Reformat a multiline at various points.                                   |
"|===========================================================================|
NextTest
Say 'Reformat multiline at various points'

Say 'Reformat from the end line'
NormalStyle
UseCase 6
Assertq $CommentableReformat

Say 'Reformat from a medial line'
NormalStyle
UseCase 6
Assert (b:case_lastline - 1) . 'CommentableReformat'

Say 'Reformat from the opening line'
NormalStyle
UseCase 6
Assert b:case_firstline . 'CommentableReformat'

EndTest
