StartTest reformat_column indented_comments

command -buffer -nargs=1 -bar ReformatCase
	\ NormalStyle | UseCase <args> | Assertq $CommentableReformat

function s:RunCase(case)
	"|===============================================|
	"| Regular format comment                        |
	"|===============================================|
	NextTest
	Say 'Regular reformat case ' . a:case
	ReformatCase a:case

	"|===============================================|
	"| Set column to be a bit shorter                |
	"|===============================================|
	NextTest
	Say 'Reformat with column=50, case ' . a:case
	let g:CommentableBlockColumn = 50
	ReformatCase a:case

	"|===============================================|
	"| Set only short subcolumn                      |
	"|===============================================|
	NextTest
	Say 'Reformat with column unset, subcolumn=50, case ' . a:case
	let g:CommentableSubColumn = 50
	ReformatCase a:case

	"|===============================================|
	"| Set both different                            |
	"|===============================================|
	NextTest
	Say 'Reformat with column=120, subcolumn=50, case ' . a:case
	let g:CommentableBlockColumn = 120
	let g:CommentableSubColumn = 50
	ReformatCase a:case
endfunction

for s:case in range(1, 5)
	call <SID>RunCase(s:case)
endfor

EndTest
