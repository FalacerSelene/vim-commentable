StartTest lisp_comments lisp_comments

command -buffer -nargs=0 LispStyle
	\   NormalStyle
	\ | let g:CommentableBlockStyle = [[';;', ';\+'], '-', '|']

"|===========================================================================|
"| Test each of the standard reformattings                                   |
"|===========================================================================|
for b:case in range(1, 4)
	NextTest
	let b:cname = 'Case ' . string(b:case) . ' - ' . repeat(';', b:case)
	Say b:cname
	LispStyle
	UseCase b:case
	Assertq $CommentableReformat
endfor

"|===========================================================================|
"| Check we're not easily confused                                           |
"|===========================================================================|
NextTest
Say 'Case 5 - Confusion check'
LispStyle
UseCase 5
Assertq $CommentableReformat

"|===========================================================================|
"| Test creation                                                             |
"|===========================================================================|
NextTest
Say 'Case 6 - Creation test'
LispStyle
call append('$', 'Some comment text!')
Assertq $CommentableCreate

EndTest
