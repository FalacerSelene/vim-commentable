"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/5_line_comment.in

"|===========================================================================|
"| Reformat a comment at each line inside it, with paraboth set and unset.   |
"|===========================================================================|
for s:paraboth in [['\m^\s*$'], []]
	for s:at_lineno in [0, 1, 2, 3, 4, 5, 6]
		NextCase

		call Out('Reformat a comment with cursor from line ' . s:at_lineno)
		Out '  With g:CommentableParaBoth ...'
		if empty(s:paraboth)
			Out '    EMPTY'
		else
			Out '    SET'
		endif

		let g:CommentableBlockStyle = ['/*', '*', '*/']
		let g:CommentableParaBoth = s:paraboth
		call append(line('$'), GetCase(1))
		let s:line = line('$') + s:at_lineno - 6
		execute s:line . 'CommentableReformat'
	endfor
endfor

"|===========================================================================|
"| Save and conclude                                                         |
"|===========================================================================|
NextCase
Out '-- End of Test --'
saveas output/reformat_5_lines.out
quitall!
