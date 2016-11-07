"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
StartTest reformat_preserve_list comment_list

"|===========================================================================|
"| Reformat without having set the intro text.                               |
"|===========================================================================|
NextCase
Out 'Reformat with ParagraphIntro unset'
let g:CommentableBlockStyle = ['/*', '*', '*/']
let g:CommentableBlockWidth = 80
call append(line('$'), GetCase(1))
$CommentableReformat

"|===========================================================================|
"| Reformat with the intro text.                                             |
"|===========================================================================|
NextCase
Out 'Reformat with ParagraphIntro set to match ''\d: '''
let g:CommentableBlockStyle = ['/*', '*', '*/']
let g:CommentableBlockWidth = 80
let g:CommentableParagraphIntro = ['\m^\d: ']
call append(line('$'), GetCase(1))
$CommentableReformat

EndTest
