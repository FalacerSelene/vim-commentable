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
catch /^Commentable:NOT YET IMPLEMENTED:/
endtry

"|===========================================================================|
"| Check NotYetImplemented is thrown for mapping                             |
"|===========================================================================|
try
	nmap ttt <Plug>(CommentableCreate)
	normal ttt
	Out 'No exception found!'
catch /^Commentable:NOT YET IMPLEMENTED:/
endtry

"|===========================================================================|
"| Save and conclude                                                         |
"|===========================================================================|
NextCase
Out '-- End of Test --'
saveas create_block.out
quitall!
