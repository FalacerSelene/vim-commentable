StartTest multilevel_reformat multilevel_comment

"|===========================================================================|
"| Reformat multilevel blocks                                                |
"|===========================================================================|
NextTest
NormalStyle
UseCase 1
Assert b:case_firstline . ',' . b:case_lastline . 'CommentableReformat'

"|===========================================================================|
"| Check that reformat from medial lines works the same                      |
"|===========================================================================|
NextTest
NormalStyle
UseCase 1
let b:first = b:case_firstline + 1
let b:last = b:case_firstline + 6
Assert b:first . ',' . b:last . 'CommentableReformat'

EndTest
