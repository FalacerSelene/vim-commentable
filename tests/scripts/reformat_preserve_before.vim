"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/multiline_comment.in

"|===========================================================================|
"| Reformat a block many times, with parabefore set to a variety of things.  |
"|===========================================================================|
function s:RunCase(parabefore)
	NextCase
	Out 'Reformat the comment with PreserveBefore ...'
	Out '  ' . string(a:parabefore)
	let g:CommentableBlockStyle = ['/*', '*', '*/']
	let g:CommentablePreserveBefore = a:parabefore
	let g:CommentablePreserveAfter = []
	let g:CommentablePreserveBoth = []
	call append(line('$'), GetCase(4))
	execute '$CommentableReformat'
endfunction

for s:parabefore in [
 \ [],
 \ [''],
 \ ['\m^\s*$'],
 \ ['e'],
 \ ['England'],
 \ ['^Bring'],
 \ ]
	call <SID>RunCase(s:parabefore)
endfor

EndTest reformat_preserve_before
