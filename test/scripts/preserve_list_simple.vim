StartTest preserve_list_simple comment_list

"|===========================================================================|
"| Reformat without having set the intro text.                               |
"|===========================================================================|
NextTest
Say 'Reformat with ParagraphIntro unset'
NormalStyle
UseCase 1
let g:CommentableBlockWidth = 80
Assertq $CommentableReformat

"|===========================================================================|
"| Reformat with the intro text.                                             |
"|===========================================================================|
NextTest
Say 'Reformat with ParagraphIntro set to match ''\d: '''
NormalStyle
UseCase 1
let g:CommentableBlockWidth = 80
let g:CommentableParagraphIntro = ['\d: ']
Assertq $CommentableReformat

"|===========================================================================|
"| Reformat with the intro text.                                             |
"|===========================================================================|
NextTest
Say 'Reformat with ParagraphIntro set to match ''well '''
NormalStyle
UseCase 1
let g:CommentableBlockWidth = 80
let g:CommentableParagraphIntro = ['well ']
Assertq $CommentableReformat

"|===========================================================================|
"| Match a sublist.                                                          |
"|===========================================================================|
NextTest
Say 'Match a nested list'
NormalStyle
UseCase 2
let g:CommentableBlockWidth = 80
let g:CommentableParagraphIntro = ['\d: ']
Assertq $CommentableReformat

"|===========================================================================|
"| Reformat with intro explicitly empty.                                     |
"|===========================================================================|
NextTest
Say 'Reformat with ParagraphIntro explicitly set empty'
NormalStyle
UseCase 1
let g:CommentableBlockWidth = 80
let g:CommentableParagraphIntro = []
Assertq $CommentableReformat

EndTest
