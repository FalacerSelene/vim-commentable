"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/multiline_comment.in

"|===========================================================================|
"| Reformat a block many times, with paraboth set to a variety of things.    |
"|===========================================================================|
function s:RunCase(paraboth)
	NextCase
	Out 'Reformat the comment with PreserveBoth ...'
	Out '  ' . string(a:paraboth)
	let g:CommentableBlockStyle = ['/*', '*', '*/']
	let g:CommentablePreserveBoth = a:paraboth
	let g:CommentablePreserveBefore = []
	let g:CommentablePreserveAfter = []
	call append(line('$'), GetCase(4))
	execute '$CommentableReformat'
endfunction

for s:paraboth in [
 \ [],
 \ [''],
 \ ['\m^\s*$'],
 \ ['e'],
 \ ['England'],
 \ ['^Bring'],
 \ ]
	call <SID>RunCase(s:paraboth)
endfor

EndTest reformat_preserve_both
