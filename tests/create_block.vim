"|=============================================================================|
"| Begin                                                                       |
"|=============================================================================|
source utils.vim
edit create_block.in

"|===========================================================================|
"| Check NotYetImplemented is thrown for command                             |
"|===========================================================================|
try
	CommentableCreate
	Out 'No exception found!'
catch /^Commentable:NotYetImplemented$/
endtry

"|===========================================================================|
"| Check NotYetImplemented is thrown for mapping                             |
"|===========================================================================|
try
	nmap ttt <Plug>(CommentableCreate)
	normal ttt
	Out 'No exception found!'
catch /^Commentable:NotYetImplemented$/
endtry

"|===========================================================================|
"| Save and conclude                                                         |
"|===========================================================================|
NextCase
Out '-- End of Test --'
saveas create_block.out
quit!
