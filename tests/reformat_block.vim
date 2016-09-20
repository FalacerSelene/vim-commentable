"|=============================================================================|
"| Begin                                                                       |
"|=============================================================================|
source utils.vim
edit reformat_block.in

"|===========================================================================|
"| Check NotYetImplemented is thrown for command                             |
"|===========================================================================|
try
	CommentableReformat
	Out 'No exception found!'
catch /^Commentable:NOT YET IMPLEMENTED:/
endtry

"|===========================================================================|
"| Check NotYetImplemented is thrown for mapping                             |
"|===========================================================================|
try
	nmap ttt <Plug>(CommentableReformat)
	normal ttt
	Out 'No exception found!'
catch /^Commentable:NOT YET IMPLEMENTED:/
endtry

"|===========================================================================|
"| Save and conclude                                                         |
"|===========================================================================|
NextCase
Out '-- End of Test --'
saveas reformat_block.out
quitall!
