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
	let l:scopes = ['b', 'g']
	let l:vars = [
	\ 'CommentableBlockStyle',
	\ 'CommentableBlockWidth',
	\ 'CommentableSubStyle',
	\ 'CommentableSubWidth',
	\ 'CommentableParaBefore',
	\ 'CommentableParaAfter',
	\ 'CommentableParaBoth',
	\ ]

	for l:var in l:vars
		for l:scope in l:scopes
			if eval("exists('" . l:scope . ':' . l:var . "')")
				execute 'unlet ' . l:scope . ':' . l:var
			endif
		endfor
	endfor
endfunction


"|===========================================================================|
"| Commands                                                                  |
"|===========================================================================|
command -nargs=1 Out call Out(<args>)
command NextCase call Out(repeat('=', 78)) | call ResetVariables()

