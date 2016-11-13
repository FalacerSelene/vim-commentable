"|===========================================================================|
"| Assert that the plugin has loaded correctly                               |
"|===========================================================================|
function AssertPluginLoad() abort
	NextCase
	Out "Assert Plugin loaded"
	if exists('g:loaded_commentable')
		Out "Plugin loaded successfully"
	else
		Out "Failed to load plugin"
		cquit!
	endif
endfunction

"|===========================================================================|
"| Output                                                                    |
"|===========================================================================|
function Out(text) abort
	if type(a:text) == type('')
		call append(line('$'), a:text)
	elseif type(a:text) == type([])
		for l:line in a:text
			call append(line('$'), l:line)
		endfor
	else
		call append(line('$'), string(a:text))
	endif
endfunction

"|===========================================================================|
"| Reset all variables                                                       |
"|===========================================================================|
function ResetVariables() abort
	let l:scopes = [b:, g:]
	let l:vars = [
	\ 'CommentableBlockStyle',
	\ 'CommentableBlockWidth',
	\ 'CommentableBlockColumn',
	\ 'CommentableSubStyle',
	\ 'CommentableSubWidth',
	\ 'CommentableSubColumn',
	\ 'CommentableParagraphIntro',
	\ ]

	for l:var in l:vars
		for l:scope in l:scopes
			if has_key(l:scope, l:var)
				unlet l:scope[l:var]
			endif
		endfor
	endfor
endfunction

"|===========================================================================|
"| Get the text in between 2 CASE statements in the input                    |
"|===========================================================================|
function GetCase(casenum) abort
	" Search from the top of the file
	call cursor(1,1)
	let l:start = search('\m^-- Start of Input --$')
	let l:end = search('\m^-- End of Input --$')
	if l:start == 0 || l:end == 0
		call Out('Could not find any input!')
		cquit!
	endif
	let l:start += 1
	let l:end -= 2

	call cursor(l:start, 1)
	let l:casestart = search('\m^-- CASE ' . string(a:casenum) . ' --$')
	if l:casestart == 0
		call Out('Could not find CASE ' . string(a:casenum))
		cquit!
	else
		let l:casestart += 1
	endif

	let l:caseend = search('\m^-- CASE ' . string(a:casenum + 1) . ' --$')
	if l:caseend == 0
		let l:caseend = l:end
	else
		let l:caseend -= 1
	endif

	let l:lines = []
	for l:lnum in range(l:casestart, l:caseend)
		call add(l:lines, getline(l:lnum))
	endfor

	return l:lines
endfunction

"|===========================================================================|
"| Start and finish the test elegantly                                       |
"|===========================================================================|
function StartTest(...) abort
	if a:0 != 2
		echoerr 'Invalid call to StartTest()'
		return
	else
		let l:testname = a:1
		let l:sourcefile = a:2
	endif

	let s:testname = l:testname
	if l:sourcefile !=# ''
		execute 'edit input/' . l:sourcefile . '.in'
	endif

	if !isdirectory('message')
		call mkdir('message')
	endif

	execute 'redir! > message/' . l:testname . '.msg'
endfunction

function EndTest() abort
	Out repeat('=', 78)
	Out '-- End of Test --'
	let l:firstline = getline(1)
	if l:firstline ==# '-- Start of Input --'
		let l:lastlinenum = 2
		while getline(l:lastlinenum) !=# '-- End of Input --'
			let l:lastlinenum += 1
		endwhile
		execute "1," . l:lastlinenum . "delete _"
		call append(line(0), '-- Start of Test --')
	endif

	redir END
	execute 'saveas! output/' . s:testname . '.out'
	quitall!
endfunction

"|===========================================================================|
"| Commands                                                                  |
"|===========================================================================|
command -bar -nargs=1 Out call Out(<args>)
command -bar -nargs=0 NextCase call Out(repeat('=', 78)) | call ResetVariables()
command -bar -nargs=0 EndTest call EndTest()
command -nargs=* StartTest call StartTest(<f-args>)

