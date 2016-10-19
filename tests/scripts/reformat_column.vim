"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/indented_comments.in

command -buffer -nargs=1 -bar ReformatCase
	\ let g:CommentableBlockStyle = ['/*', '*', '*/'] |
	\ call append(line('$'), GetCase(<args>))         |
	\ execute line('$') . 'CommentableReformat'

for s:case in range(1, 5)
	"|===============================================|
	"| Regular format comment                        |
	"|===============================================|
	NextCase
	call Out('Regular reformat case ' . s:case)
	ReformatCase s:case

	"|===============================================|
	"| Set column to be a bit shorter                |
	"|===============================================|
	NextCase
	call Out('Reformat with column=50, case ' . s:case)
	let g:CommentableBlockColumn = 50
	ReformatCase s:case

	"|===============================================|
	"| Set only short subcolumn                      |
	"|===============================================|
	NextCase
	call Out('Reformat with column unset, subcolumn=50, case ' . s:case)
	let g:CommentableSubColumn = 50
	ReformatCase s:case

	"|===============================================|
	"| Set both different                            |
	"|===============================================|
	NextCase
	call Out('Reformat with column=120, subcolumn=50, case ' . s:case)
	let g:CommentableBlockColumn = 120
	let g:CommentableSubColumn = 50
	ReformatCase s:case
endfor

"|===========================================================================|
"| Save and conclude                                                         |
"|===========================================================================|
NextCase
Out '-- End of Test --'
saveas output/reformat_column.out
quitall!
