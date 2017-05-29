StartTest create_block_config_style create_single_comment

let s:cases = [
	\ ['Case 1 - default', ['/*', '*', '*/']],
	\ ['Case 2 - perlish style', ['#=', '=', '=#']],
	\ ['Case 3 - vimmish style', ['"|', '=', '|']],
	\ ['Case 4 - style with no final part', ['((', '-', '']],
	\ ['Case 5 - style with no medial part', [';;', '', '']],
	\ ['Case 6 - style with initial and medial only', [';;', '', ';;']],
	\ ]

for [b:text, b:style] in s:cases
	NextTest
	Say b:text
	UseCase 1
	let g:CommentableBlockStyle = b:style
	Assertq $CommentableCreate
endfor

EndTest
