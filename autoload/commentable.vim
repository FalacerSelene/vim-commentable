"|===========================================================================|
"|                                                                           |
"|         FILE:  autoload/commentable.vim                                   |
"|                                                                           |
"|  DESCRIPTION:  Primary autoload functions for plugin.                     |
"|                                                                           |
"|       AUTHOR:  @FalacerSelene                                             |
"|      CONTACT:  < github at adamselene dot net >                           |
"|      LICENCE:  See LICENCE.md                                             |
"|      VERSION:  See plugin/commentable.vim                                 |
"|                                                                           |
"|===========================================================================|

"|===========================================================================|
"|                            SCRIPT CONSTANTS                               |
"|===========================================================================|
let s:t_number = v:version >= 800 ? v:t_number : type(0)
let s:t_list   = v:version >= 800 ? v:t_list   : type([])
let s:t_string = v:version >= 800 ? v:t_string : type('')

"|===========================================================================|
"|                            PUBLIC FUNCTIONS                               |
"|===========================================================================|

"|===========================================================================|
"| commentable#IsCommentBlock(lineno) abort {{{                              |
"|                                                                           |
"| Determines whether the given linenumber is part of a comment block or     |
"| not.                                                                      |
"|                                                                           |
"| PARAMS:                                                                   |
"|   lineno) The line number to check.                                       |
"|                                                                           |
"| Returns zero if true, non-zero if false. May throw.                       |
"|===========================================================================|
function! commentable#IsCommentBlock(lineno) abort
	let l:block = commentable#block#New(indent(a:lineno))
	return l:block.LineMatches(a:lineno)
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| commentable#Reformat(lineno) abort {{{                                    |
"|                                                                           |
"| Reformat the comment block on the given line. Reformatting includes:      |
"| - Aligning all the lines.                                                 |
"| - Setting the line length to be correct.                                  |
"| - Ensuring that all the text flows correctly from one line to the next.   |
"| - Conforming to paragraph configuration.                                  |
"|                                                                           |
"| PARAMS:                                                                   |
"|   lineno) Reformat the comment block at this line. If the given line does |
"|           not have a comment block on it, then do nothing.                |
"|                                                                           |
"| Returns nothing. May throw.                                               |
"|===========================================================================|
function! commentable#Reformat(lineno) abort
	let l:indent = indent(a:lineno)
	let l:indentchars = substitute(getline(a:lineno), '\m^\(\s*\).*', '\1', '')
	let l:blockwidth = <SID>GetCommentBlockWidth(l:indent)
	let l:block = commentable#block#New(l:indent)
	let [l:startline, l:endline] = l:block.AddExisting(a:lineno)
	let l:lines = l:block.GetFormat(l:blockwidth)
	call map(l:lines, 'l:indentchars . v:val')

	"|===============================================|
	"| Changes occur after this point.               |
	"|===============================================|
	execute l:startline . ',' . l:endline . 'call <SID>ReplaceLines(l:lines)'
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| commentable#CreateBlock() abort range {{{                                 |
"|                                                                           |
"| Create a new comment block comprising the text in the given range.        |
"|                                                                           |
"| PARAMS: NONE                                                              |
"|                                                                           |
"| Returns nothing. May throw.                                               |
"|===========================================================================|
function! commentable#CreateBlock() abort range
	let l:indent = indent(a:firstline)
	let l:indentchars = substitute(getline(a:firstline), '\m^\(\s*\).*', '\1', '')
	let l:blockwidth = <SID>GetCommentBlockWidth(l:indent)
	let l:lines = getline(a:firstline, a:lastline)
	call map(l:lines, '<SID>RemoveIndent(l:indent, v:val)')

	let l:block = commentable#block#New(l:indent)
	let l:curpar = commentable#paragraph#New(l:lines[0])
	let l:lastlineblank = 0
	for l:line in l:lines[1:]
		if l:line =~# '\m^\s*$'
			call l:block.AddParagraph(l:curpar)
			let l:curpar = commentable#paragraph#New(l:line)
			let l:lastlineblank = 1
		elseif l:curpar.IsInParagraph(l:line) && (!l:lastlineblank)
			call l:curpar.AddLine(l:line)
		else
			call l:block.AddParagraph(l:curpar)
			let l:curpar = commentable#paragraph#New(l:line)
			let l:lastlineblank = 0
		endif
	endfor
	call l:block.AddParagraph(l:curpar)

	let l:lines = l:block.GetFormat(l:blockwidth)
	call map(l:lines, 'l:indentchars . v:val')

	"|===============================================|
	"| Changes occur after this point.               |
	"|===============================================|
	execute a:firstline . ',' . a:lastline . 'call <SID>ReplaceLines(l:lines)'
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| commentable#GetVar(varname) abort {{{                                     |
"|                                                                           |
"| Fetch a configuration variable.                                           |
"|                                                                           |
"| PARAMS:                                                                   |
"|   varname) The config item to fetch.                                      |
"|                                                                           |
"| Returns a buffer local version of the variable, if one exists. Else,      |
"| returns the global version. If neither is set, throws.                    |
"|===========================================================================|
function! commentable#GetVar(varname) abort
	for l:t in [b:, g:]
		if has_key(l:t, a:varname)
			let l:d = l:t
			break
		endif
	endfor

	if !has_key(l:, 'd')
		throw 'Commentable:NO VALUE:' . a:varname
	endif

	return get(l:d, a:varname)
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| commentable#StripSpaces(line) abort {{{                                   |
"|                                                                           |
"| Strip leading and trailing spaces from a line.                            |
"|                                                                           |
"| PARAMS:                                                                   |
"|   line) Line to strip.                                                    |
"|                                                                           |
"| Returns the stripped line.                                                |
"|===========================================================================|
function! commentable#StripSpaces(line) abort
	return substitute(a:line, '\m^\s*\(.*[^[:space:]]\)\s*$', '\1', '')
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"|                            PRIVATE FUNCTIONS                              |
"|===========================================================================|

"|===========================================================================|
"| s:GetCommentBlockWidth(amount_indented) abort {{{                         |
"|===========================================================================|
function! s:GetCommentBlockWidth(amount_indented) abort
	let l:is_indented = a:amount_indented !=# 0

	"|===============================================|
	"| Get the width.                                |
	"|===============================================|
	if l:is_indented
		try
			let l:width = commentable#GetVar('CommentableSubWidth')
			let l:width_var = 'CommentableSubWidth'
		catch /Commentable:NO VALUE:/
		endtry
	endif

	if ! exists('l:width')
		try
			let l:width = commentable#GetVar('CommentableBlockWidth')
			let l:width_var = 'CommentableBlockWidth'
		catch /Commentable:NO VALUE:/
		endtry
	endif

	"|===============================================|
	"| Get the column. Fallback to textwidth.        |
	"|===============================================|
	if l:is_indented
		try
			let l:column = commentable#GetVar('CommentableSubColumn')
			let l:column_var = 'CommentableSubColumn'
		catch /Commentable:NO VALUE:/
		endtry
	endif

	if ! exists('l:column')
		try
			let l:column = commentable#GetVar('CommentableBlockColumn')
			let l:column_var = 'CommentableBlockColumn'
		catch /Commentable:NO VALUE:/
			let l:column = &textwidth > 0 ? &textwidth : 80
			let l:column_var = 'textwidth'
		endtry
	endif

	"|===============================================|
	"| Validate both.                                |
	"|===============================================|
	for [l:elem_n, l:var_n] in [['l:width', 'l:width_var'],
	 \                          ['l:column', 'l:column_var']]
		if exists(l:elem_n) && exists(l:var_n)
			let l:elem = eval(l:elem_n)
			if type(l:elem) !=# s:t_number ||
			 \ l:elem <= 0
				throw 'Commentable:INVALID SETTING:' . eval(l:var_n)
			endif
		endif
	endfor

	"|===============================================|
	"| Now find the minimun block width.             |
	"|===============================================|
	let l:min = l:column - a:amount_indented
	if exists('l:width')
		let l:min = min([l:min, l:width])
	endif

	return l:min
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:GetTempRegs() abort {{{                                                 |
"|===========================================================================|
function! s:GetTempRegs() abort
	return [@-,@0,@1,@2,@3,@4,@5,@6,@7,@8,@9,@"]
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:RestoreTempRegs(saved) abort {{{                                        |
"|===========================================================================|
function! s:RestoreTempRegs(saved) abort
	let [@-,@0,@1,@2,@3,@4,@5,@6,@7,@8,@9,@"] = a:saved
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:ReplaceLines(with) abort range {{{                                      |
"|                                                                           |
"| Replaces lines in range with lines given as 'with'.                       |
"|                                                                           |
"| This function inherently has side-effects! But tries to keep them at a    |
"| minimum.                                                                  |
"|                                                                           |
"| PARAMS:                                                                   |
"|   with) Lines to use instead.                                             |
"|                                                                           |
"| Returns nothing.                                                          |
"|===========================================================================|
function! s:ReplaceLines(with) abort range
	let l:savedreg = <SID>GetTempRegs()
	let l:cursorpos = exists('*getcurpos') ? getcurpos() : getpos('.')
	keepmarks execute a:firstline . ',' . a:lastline . 'delete _'
	call append(a:firstline - 1, a:with)
	call setpos('.', l:cursorpos)
	call <SID>RestoreTempRegs(l:savedreg)
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:RemoveIndent(size, line) abort {{{                                      |
"|                                                                           |
"| Remove indentchars from a given line.                                     |
"|                                                                           |
"| PARAMS:                                                                   |
"|   size) Size of indent to remove.                                         |
"|   line) Line to remove chars from.                                        |
"|                                                                           |
"| Returns line with chars removed.                                          |
"|===========================================================================|
function! s:RemoveIndent(size, line) abort
	let l:sizeleft = a:size
	let l:line = a:line
	while l:sizeleft > 0                            &&
	 \    (strlen(l:line) > 0                       &&
	 \     (l:line[0] ==# ' ' || l:line[0] ==# "\t")  )
		if l:line[0] ==# ' '
			let l:sizeleft -= 1
			let l:line = l:line[1:]
		elseif l:line[0] ==# "\t"
			let l:sizeleft -= &tabstop
			let l:line = l:line[1:]
		else
			let l:sizeleft = 0
		endif
	endwhile

	return l:line
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
