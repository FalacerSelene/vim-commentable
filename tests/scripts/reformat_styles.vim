StartTest reformat_styles comment_styles

"|===========================================================================|
"| Reformat a C-style comment with both styles set.                          |
"|===========================================================================|
NextCase
Out 'Reformat C-style comments with both styles set'

Out 'C style set'
NormalStyle
InputCase 1
$CommentableReformat

Out 'Lua style set'
let g:CommentableBlockStyle = ['--[', '=', ']--']
InputCase 1
$CommentableReformat

"|===========================================================================|
"| Reformat a Lua-style comment with both styles set.                        |
"|===========================================================================|
NextCase
Out 'Reformat Lua-style comments with both styles set'

Out 'C style set'
NormalStyle
InputCase 2
$CommentableReformat

Out 'Lua style set'
let g:CommentableBlockStyle = ['--[', '=', ']--']
InputCase 2
$CommentableReformat

"|===========================================================================|
"| Reformat a comment with only a leader.                                    |
"|===========================================================================|
NextCase
Out 'Reformat a comment with only a leader'

Out 'Normal C-style'
NormalStyle
InputCase 3
$CommentableReformat

Out 'C style with no final'
let g:CommentableBlockStyle = ['/*', '*', '']
InputCase 3
$CommentableReformat

Out 'C style with no medial'
let g:CommentableBlockStyle = ['/*', '', '*/']
InputCase 3
$CommentableReformat

Out 'C style with no medial or final'
let g:CommentableBlockStyle = ['/*', '', '']
InputCase 3
$CommentableReformat

"|===========================================================================|
"| Reformat a comment with only a final.                                     |
"|===========================================================================|
NextCase
Out 'Reformat a comment with only a final'

Out 'Normal C-style'
NormalStyle
InputCase 4
$CommentableReformat

Out 'C style with no final'
let g:CommentableBlockStyle = ['/*', '*', '']
InputCase 4
$CommentableReformat

Out 'C style with no medial'
let g:CommentableBlockStyle = ['/*', '', '*/']
InputCase 4
$CommentableReformat

Out 'C style with no medial or final'
let g:CommentableBlockStyle = ['/*', '', '']
InputCase 4
$CommentableReformat

"|===========================================================================|
"| Reformat a multiline comment down to one line.                            |
"|===========================================================================|
NextCase
Out 'Reformat a multiline comment down to one line'
NormalStyle
InputCase 5
$CommentableReformat

"|===========================================================================|
"| Reformat a multiline at various points.                                   |
"|===========================================================================|
NextCase
Out 'Reformat multiline at various points'

Out 'Reformat from the end line'
NormalStyle
InputCase 6
$CommentableReformat

Out 'Reformat from a medial line'
NormalStyle
InputCase 6
execute ((b:case_lastline - 1) . 'CommentableReformat')

Out 'Reformat from the opening line'
NormalStyle
InputCase 6
execute b:case_firstline . 'CommentableReformat'

EndTest
