StartTest multilevel_join multilevel_comment

"|===========================================================================|
"| Use Create to join blocks together                                        |
"|===========================================================================|
NextTest
NormalStyle
UseCase 1
Assert b:case_firstline . ',' . b:case_lastline . 'CommentableCreate'

"|===========================================================================|
"| Check that joining from medial lines works the same                       |
"|===========================================================================|
NextTest
NormalStyle
UseCase 1
let b:first = b:case_firstline + 1
let b:last = b:case_firstline + 6
Assert b:first . ',' . b:last . 'CommentableCreate'

EndTest
