"|===========================================================================|
"|                                                                           |
"|         FILE:  autoload/commentable/util.vim                              |
"|                                                                           |
"|  DESCRIPTION:  General purpose utilities.                                 |
"|                                                                           |
"|===========================================================================|

"|===========================================================================|
"|                              PUBLIC FUNCTIONS                             |
"|===========================================================================|

"|===========================================================================|
"| commentable#util#GetVar(var_name) abort {{{                               |
"|                                                                           |
"| Fetch a configuration variable.                                           |
"|                                                                           |
"| PARAMS:                                                                   |
"|   var_name) The config item to fetch.                                     |
"|                                                                           |
"| Returns a buffer local version of the variable, if one exists. Else,      |
"| returns the global version. If neither is set, throws.                    |
"|===========================================================================|
function! commentable#util#GetVar(var_name) abort
	for l:t in [b:, g:]
		if has_key(l:t, a:var_name)
			let l:d = l:t
			break
		endif
	endfor

	if !has_key(l:, 'd')
		throw 'Commentable:NO VALUE:' . a:var_name
	endif

	return get(l:d, a:var_name)
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| commentable#util#StripSpaces(line) abort {{{                              |
"|                                                                           |
"| Strip leading and trailing spaces from a line.                            |
"|                                                                           |
"| PARAMS:                                                                   |
"|   line) Line to strip.                                                    |
"|                                                                           |
"| Returns the stripped line.                                                |
"|===========================================================================|
function! commentable#util#StripSpaces(line) abort
	return substitute(a:line, '\m^\s*\(.*[^[:space:]]\)\s*$', '\1', '')
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
