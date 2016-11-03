"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/multiline_comment.in

"|===========================================================================|
"| Reformat a block many times, with paraafter set to a variety of things.   |
"|===========================================================================|
function s:RunCase(paraafter)
	NextCase
	Out 'Reformat the comment with PreserveAfter ...'
	Out '  ' . string(a:paraafter)
	let g:CommentableBlockStyle = ['/*', '*', '*/']
	let g:CommentablePreserveAfter = a:paraafter
	let g:CommentablePreserveBefore = []
	let g:CommentablePreserveBoth = []
	call append(line('$'), GetCase(4))
	execute '$CommentableReformat'
endfunction

for s:paraafter in [
 \ [],
 \ [''],
 \ ['\m^\s*$'],
 \ ['e'],
 \ ['England'],
 \ ['^Bring'],
 \ ]
	call <SID>RunCase(s:paraafter)
endfor

EndTest reformat_preserve_after
