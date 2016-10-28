"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
edit input/comment_styles.in

"|===========================================================================|
"| Reformat a C-style comment with both styles set.                          |
"|===========================================================================|
NextCase
Out 'Reformat C-style comments with both styles set'

Out 'C style set'
let g:CommentableBlockStyle = ['/*', '*', '*/']
call append(line('$'), GetCase(1))
execute line('$') . 'CommentableReformat'

Out 'Lua style set'
let g:CommentableBlockStyle = ['--[', '=', ']--']
call append(line('$'), GetCase(1))
execute line('$') . 'CommentableReformat'

"|===========================================================================|
"| Reformat a Lua-style comment with both styles set.                        |
"|===========================================================================|
NextCase
Out 'Reformat Lua-style comments with both styles set'

Out 'C style set'
let g:CommentableBlockStyle = ['/*', '*', '*/']
call append(line('$'), GetCase(2))
execute line('$') . 'CommentableReformat'

Out 'Lua style set'
let g:CommentableBlockStyle = ['--[', '=', ']--']
call append(line('$'), GetCase(2))
execute line('$') . 'CommentableReformat'

"|===========================================================================|
"| Reformat a comment with only a leader.                                    |
"|===========================================================================|
NextCase
Out 'Reformat a comment with only a leader'

Out 'Normal C-style'
let g:CommentableBlockStyle = ['/*', '*', '*/']
call append(line('$'), GetCase(3))
execute line('$') . 'CommentableReformat'

Out 'C style with no final'
let g:CommentableBlockStyle = ['/*', '*', '']
call append(line('$'), GetCase(3))
execute line('$') . 'CommentableReformat'

Out 'C style with no medial'
let g:CommentableBlockStyle = ['/*', '', '*/']
call append(line('$'), GetCase(3))
execute line('$') . 'CommentableReformat'

Out 'C style with no medial or final'
let g:CommentableBlockStyle = ['/*', '', '']
call append(line('$'), GetCase(3))
execute line('$') . 'CommentableReformat'

"|===========================================================================|
"| Reformat a comment with only a final.                                     |
"|===========================================================================|
NextCase
Out 'Reformat a comment with only a final'

Out 'Normal C-style'
let g:CommentableBlockStyle = ['/*', '*', '*/']
call append(line('$'), GetCase(4))
execute line('$') . 'CommentableReformat'

Out 'C style with no final'
let g:CommentableBlockStyle = ['/*', '*', '']
call append(line('$'), GetCase(4))
execute line('$') . 'CommentableReformat'

Out 'C style with no medial'
let g:CommentableBlockStyle = ['/*', '', '*/']
call append(line('$'), GetCase(4))
execute line('$') . 'CommentableReformat'

Out 'C style with no medial or final'
let g:CommentableBlockStyle = ['/*', '', '']
call append(line('$'), GetCase(4))
execute line('$') . 'CommentableReformat'

"|===========================================================================|
"| Reformat a multiline comment down to one line.                            |
"|===========================================================================|
NextCase
Out 'Reformat a multiline comment down to one line'
let g:CommentableBlockStyle = ['/*', '*', '*/']
call append(line('$'), GetCase(5))
execute line('$') . 'CommentableReformat'

"|===========================================================================|
"| Reformat a multiline at various points.                                   |
"|===========================================================================|
NextCase
Out 'Reformat multiline at various points'

Out 'Reformat from the end line'
let g:CommentableBlockStyle = ['/*', '*', '*/']
call append(line('$'), GetCase(6))
execute line('$') . 'CommentableReformat'

Out 'Reformat from a medial line'
let g:CommentableBlockStyle = ['/*', '*', '*/']
call append(line('$'), GetCase(6))
execute (line('$') - 1) . 'CommentableReformat'

Out 'Reformat from the opening line'
let g:CommentableBlockStyle = ['/*', '*', '*/']
call append(line('$'), GetCase(6))
let s:linenum = line('$')
let s:linetext = getline(s:linenum)
while match(s:linetext, '\V\/*') == -1
	let s:linenum -= 1
	let s:linetext = getline(s:linenum)
endwhile
execute s:linenum . 'CommentableReformat'

"|===========================================================================|
"| Save and conclude                                                         |
"|===========================================================================|
NextCase
Out '-- End of Test --'
saveas output/reformat_styles.out
quitall!
