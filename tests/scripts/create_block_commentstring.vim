"|===========================================================================|
"| Begin                                                                     |
"|===========================================================================|
source utils.vim
StartTest create_block_commentstring create_single_comment

"|===========================================================================|
"| Create a comment, with no style set. Should fall back to comment string.  |
"|===========================================================================|
function RunCase(comstr)
	NextCase
	let &commentstring = a:comstr
	call append(line('$'), GetCase(1))
	try
		$CommentableCreate
	catch
		Out 'Caught exception!'
		Out v:exception
	endtry
endfunction

for s:comstr in ['/*%s*/', '>>>%s<<<']
	call RunCase(s:comstr)
endfor

EndTest
