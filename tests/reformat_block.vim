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
catch /^Commentable:NotYetImplemented$/
endtry

"|===========================================================================|
"| Check NotYetImplemented is thrown for mapping                             |
"|===========================================================================|
try
	nmap ttt <Plug>(CommentableReformat)
	normal ttt
	Out 'No exception found!'
catch /^Commentable:NotYetImplemented$/
endtry

"|===========================================================================|
"| Save and conclude                                                         |
"|===========================================================================|
NextCase
Out '-- End of Test --'
saveas reformat_block.out
quit!
