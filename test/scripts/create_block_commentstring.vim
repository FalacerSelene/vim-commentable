StartTest create_block_commentstring create_single_comment

"|===========================================================================|
"| Create a comment, with no style set. Should fall back to comment string.  |
"|===========================================================================|
for b:comstr in ['/*%s*/', '>>>%s<<<']
	NextTest
	let &commentstring = b:comstr
	UseCase 1
	Assertq $CommentableCreate
endfor

EndTest
