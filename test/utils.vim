"|===========================================================================|
"| Assert that the plugin has loaded correctly                               |
"|===========================================================================|
function AssertPluginLoad() abort
	NextCase
	Say "Assert Plugin loaded"
	if exists('g:loaded_commentable')
		Say "Plugin loaded successfully"
	else
		Say "Failed to load plugin"
		cquit!
	endif
endfunction

"|===========================================================================|
"| Output                                                                    |
"|===========================================================================|
function Say(...) abort
	for l:arg in a:000
		if type(l:arg) == type('')
			call append('$', l:arg)
		elseif type(a:text) == type([])
			for l:line in l:arg
				call append('$', l:line)
			endfor
		else
			call append('$', string(l:arg))
		endif
	endfor
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
		call Say('Could not find any input!')
		cquit!
	endif
	let l:start += 1
	let l:end -= 2

	call cursor(l:start, 1)
	let l:casestart = search('\m^-- CASE ' . string(a:casenum) . ' --$')
	if l:casestart == 0
		call Say('Could not find CASE ' . string(a:casenum))
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
	if a:0 == 0 || a:0 > 2
		echoerr 'Invalid call to StartTest()'
		return
	endif

	let s:testname = a:1

	if a:0 == 2
		execute 'edit input/' . a:2 . '.in'
	endif

	"|===============================================|
	"| Delete blank lines at the end                 |
	"|===============================================|
	while getline('$') =~# '\m^\s*$' | $delete _ | endwhile

	if !isdirectory('message')
		call mkdir('message')
	endif

	execute 'redir! > message/' . s:testname . '.msg'
endfunction

function EndTest() abort
	Say repeat('=', 78)
	Say '-- End of Test --'
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
command -bar -nargs=* Say call Say(<args>)
command -bar -nargs=0 NextTest call Say(repeat('=', 78)) | call ResetVariables()
command -bar -nargs=0 EndTest call EndTest()
command -nargs=* StartTest call StartTest(<f-args>)
command -bar -nargs=1 UseCase
 \   let b:case_firstline = line('$') + 1
 \ | call append('$', GetCase(<args>))
 \ | let b:case_lastline = line('$')
command -bar -nargs=0 NormalStyle let g:CommentableBlockStyle = ['/*', '*', '*/']
command -bar -nargs=0 SayException
 \   Say 'Caught exception!'
 \ | Say v:exception
command -nargs=* Assertq try | execute <q-args> | catch | SayException | endtry
command -nargs=* Assert try | execute <args> | catch | SayException | endtry
