"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/indented_comments.in

command -buffer -nargs=1 -bar ReformatCase
	\ let g:CommentableBlockStyle = ['/*', '*', '*/'] |
	\ call append(line('$'), GetCase(<args>))         |
	\ execute line('$') . 'CommentableReformat'

function s:RunCase(case)
	"|===============================================|
	"| Regular format comment                        |
	"|===============================================|
	NextCase
	Out 'Regular reformat case ' . a:case
	ReformatCase a:case

	"|===============================================|
	"| Set column to be a bit shorter                |
	"|===============================================|
	NextCase
	Out 'Reformat with column=50, case ' . a:case
	let g:CommentableBlockColumn = 50
	ReformatCase a:case

	"|===============================================|
	"| Set only short subcolumn                      |
	"|===============================================|
	NextCase
	Out 'Reformat with column unset, subcolumn=50, case ' . a:case
	let g:CommentableSubColumn = 50
	ReformatCase a:case

	"|===============================================|
	"| Set both different                            |
	"|===============================================|
	NextCase
	Out 'Reformat with column=120, subcolumn=50, case ' . a:case
	let g:CommentableBlockColumn = 120
	let g:CommentableSubColumn = 50
	ReformatCase a:case
endfunction

for s:case in range(1, 5)
	call <SID>RunCase(s:case)
endfor

EndTest reformat_column
