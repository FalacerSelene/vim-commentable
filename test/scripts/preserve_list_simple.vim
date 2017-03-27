StartTest preserve_list_simple comment_list

"|===========================================================================|
"| Reformat without having set the intro text.                               |
"|===========================================================================|
NextCase
Out 'Reformat with ParagraphIntro unset'
NormalStyle
InputCase 1
let g:CommentableBlockWidth = 80
$CommentableReformat

"|===========================================================================|
"| Reformat with the intro text.                                             |
"|===========================================================================|
NextCase
Out 'Reformat with ParagraphIntro set to match ''\d: '''
NormalStyle
InputCase 1
let g:CommentableBlockWidth = 80
let g:CommentableParagraphIntro = ['\m^\d: ']
$CommentableReformat

"|===========================================================================|
"| Reformat with intro explicitly empty.                                     |
"|===========================================================================|
NextCase
Out 'Reformat with ParagraphIntro explicitly set empty'
NormalStyle
InputCase 1
let g:CommentableBlockWidth = 80
let g:CommentableParagraphIntro = []
$CommentableReformat

EndTest
