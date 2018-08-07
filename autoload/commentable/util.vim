"|===========================================================================|
"|                                                                           |
"|         FILE:  autoload/commentable/util.vim                              |
"|                                                                           |
"|  DESCRIPTION:  General purpose utilities.                                 |
"|                                                                           |
"|===========================================================================|

"|===========================================================================|
"|                            PUBLIC FUNCTIONS                               |
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
			return get(l:t, a:var_name)
		endif
	endfor

	throw 'Commentable:NO VALUE:' . a:var_name
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| commentable#util#HasVar(var_name) abort {{{                               |
"|                                                                           |
"| Determine if GetVar(var_name) would throw.                                |
"|                                                                           |
"| PARAMS:                                                                   |
"|   var_name) The config item to check.                                     |
"|===========================================================================|
function! commentable#util#HasVar(var_name) abort
	for l:t in [b:, g:]
		if has_key(l:t, a:var_name)
			return 1
		endif
	endfor

	return 0
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
