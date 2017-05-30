"|===========================================================================|
"|                                                                           |
"|         FILE:  autoload/commentable/style.vim                             |
"|                                                                           |
"|  DESCRIPTION:  Style reading abstraction class.                           |
"|                                                                           |
"|===========================================================================|

"|===========================================================================|
"|                            SCRIPT CONSTANTS                               |
"|===========================================================================|
let s:t_number = v:version >= 800 ? v:t_number : type(0)
let s:t_list   = v:version >= 800 ? v:t_list   : type([])
let s:t_string = v:version >= 800 ? v:t_string : type('')

"|===========================================================================|
"|                               CONSTRUCTOR                                 |
"|===========================================================================|

"|===========================================================================|
"| commentable#style#New() abort {{{                                         |
"|                                                                           |
"| Create a new style object.                                                |
"|                                                                           |
"| PARAMS: None.                                                             |
"|                                                                           |
"| Returns the style object.                                                 |
"|===========================================================================|
function! commentable#style#New() abort
	let l:style = {
	 \ 'Refresh'      : function('<SID>Refresh'),
	 \ 'SetIndented'  : function('<SID>SetIndented'),
	 \ 'GetInitial'   : function('<SID>GetInitial'),
	 \ 'GetInitMatch' : function('<SID>GetInitMatch'),
	 \ 'GetMedial'    : function('<SID>GetMedial'),
	 \ 'GetFinal'     : function('<SID>GetFinal'),
	 \ 'GetSpacer'    : function('<SID>GetSpacer'),
	 \ '_GetRawStyles': function('<SID>GetRawStyles'),
	 \ '_indented'    : 0,
	 \ }

	call l:style.Refresh()

	return l:style
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"|                              PUBLIC METHODS                               |
"|===========================================================================|

"|===========================================================================|
"| style.Refresh() abort dict {{{                                            |
"|                                                                           |
"| Refresh the underlying styles.                                            |
"|                                                                           |
"| PARAMS: None.                                                             |
"|                                                                           |
"| Returns nothing.                                                          |
"|===========================================================================|
function! s:Refresh() abort dict
	call l:self._GetRawStyles()

	call <SID>ValidateStyle(l:self.raw_top, l:self.raw_top_source)
	let l:self.top = <SID>ReadStyle(<SID>PrepareStyle(l:self.raw_top))

	call <SID>ValidateStyle(l:self.raw_sub, l:self.raw_sub_source)
	let l:self.sub = <SID>ReadStyle(<SID>PrepareStyle(l:self.raw_sub))
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| style.SetIndented(indented) abort dict {{{                                |
"|                                                                           |
"| Set whether or not the style is for an indented block.                    |
"|                                                                           |
"| PARAMS:                                                                   |
"|   indented) Is this for an indented block?                                |
"|                                                                           |
"| Returns nothing.                                                          |
"|===========================================================================|
function! s:SetIndented(indented) abort dict
	let l:self._indented = ((a:indented > 0) ? 1 : 0)
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| style.GetInitial() abort dict {{{                                         |
"|                                                                           |
"| Get a style initial.                                                      |
"|                                                                           |
"| PARAMS: None.                                                             |
"|                                                                           |
"| Returns the style initial (for constructors).                             |
"|===========================================================================|
function! s:GetInitial() abort dict
	return l:self[l:self._indented ? 'sub' : 'top'].initial
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| style.GetInitMatch() abort dict {{{                                       |
"|                                                                           |
"| Get a style initial matcher.                                              |
"|                                                                           |
"| PARAMS: None.                                                             |
"|                                                                           |
"| Returns the style initial matcher (for recognising reformatters).         |
"|===========================================================================|
function! s:GetInitMatch() abort dict
	return l:self[l:self._indented ? 'sub' : 'top'].initial_regex
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| style.GetMedial() abort dict {{{                                          |
"|                                                                           |
"| Get a style medial.                                                       |
"|                                                                           |
"| PARAMS: None.                                                             |
"|                                                                           |
"| Returns the style medial.                                                 |
"|===========================================================================|
function! s:GetMedial() abort dict
	return l:self[l:self._indented ? 'sub' : 'top'].medial
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| style.GetFinal() abort dict {{{                                           |
"|                                                                           |
"| Get a style final.                                                        |
"|                                                                           |
"| PARAMS: None.                                                             |
"|                                                                           |
"| Returns the style final.                                                  |
"|===========================================================================|
function! s:GetFinal() abort dict
	return l:self[l:self._indented ? 'sub' : 'top'].final
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| style.GetSpacer() abort dict {{{                                          |
"|                                                                           |
"| Get a style spacer.                                                       |
"|                                                                           |
"| PARAMS: None.                                                             |
"|                                                                           |
"| Returns the style spacer.                                                 |
"|===========================================================================|
function! s:GetSpacer() abort dict
	return l:self[l:self._indented ? 'sub' : 'top'].spacer
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"|                             PRIVATE METHODS                               |
"|===========================================================================|

"|===========================================================================|
"| style._GetRawStyles() abort dict {{{                                      |
"|                                                                           |
"| Get the raw styles form the environment.                                  |
"|                                                                           |
"| PARAMS: None.                                                             |
"|                                                                           |
"| Returns nothing. Fills in the styles in the object.                       |
"|===========================================================================|
function! s:GetRawStyles() abort dict
	try
		let l:toplevel = commentable#util#GetVar('CommentableBlockStyle')
		let l:topsource = 'CommentableBlockStyle'
	catch /Commentable:NO VALUE:/
	endtry

	if !has_key(l:, 'topsource')
		let l:toplevel = <SID>StyleFromCommentString()
		let l:topsource = '&commentstring'
	endif

	try
		let l:substyle = commentable#util#GetVar('CommentableSubStyle')
		let l:subsource = 'CommentableSubStyle'
	catch /Commentable:NO VALUE:/
	endtry

	if !has_key(l:, 'subsource')
		let l:substyle = l:toplevel
		let l:subsource = l:topsource
	endif

	let l:self.raw_top = l:toplevel
	let l:self.raw_top_source = l:topsource
	let l:self.raw_sub = l:substyle
	let l:self.raw_sub_source = l:subsource
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"|                             PRIVATE FUNCTIONS                             |
"|===========================================================================|

"|===========================================================================|
"| s:StyleFromCommentString() abort {{{                                      |
"|                                                                           |
"| Generate a style from the 'commentstring' setting.                        |
"|                                                                           |
"| PARAMS: None.                                                             |
"|                                                                           |
"| Returns the style. Throws if the 'commentstring' does not contain '%s'.   |
"|===========================================================================|
function! s:StyleFromCommentString() abort
	let [l:fullmatch, l:start, l:end; l:_] =
	 \  matchlist(&commentstring, '\v^(.*)\%s(.*)$')

	if l:fullmatch ==# ''
		throw 'Commentable:INVALID SETTING:&commentstring'
	endif

	return [l:start, '', l:end, '']
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:ValidateStyle(style, source) abort {{{                                  |
"|                                                                           |
"| Assert that a style is valid input for <SID>ReadStyle.                    |
"|                                                                           |
"| In order to be valid a style must:                                        |
"| - Be a list.                                                              |
"| - Be 3 or 4 items long.                                                   |
"| - Contain only strings.  However, the first element may also be a 2-list  |
"|   of strings.                                                             |
"| - Have no leading whitespace in the initial item.                         |
"| - Have no trailing whitespace in the third item.                          |
"|                                                                           |
"| PARAMS:                                                                   |
"|   style) The raw style to check.                                          |
"|   source) The source of the style. Used in error messages.                |
"|                                                                           |
"| Returns nothing. Throws if the style is not valid.                        |
"|===========================================================================|
function! s:ValidateStyle(style, source) abort
	if type(a:style) !=# s:t_list                   ||
	 \ ( len(a:style) !=# 3 && len(a:style) !=# 4 )
		throw 'Commentable:INVALID SETTING:' . a:source
	endif

	let l:first = a:style[0]
	let l:rest = a:style[1:]

	if type(l:first) ==# s:t_string
		"|===============================================|
		"| Must have no leading spaces                   |
		"|===============================================|
		if l:first ==# '' || match(l:first, '^[[:space:]]') !=# -1
			throw 'Commentable:INVALID SETTING:' . a:source
		endif
	elseif type(l:first) ==# s:t_list
		"|===============================================|
		"| Must be a 2-list of strings                   |
		"|===============================================|
		if len(l:first) !=# 2
			throw 'Commentable:INVALID SETTING:' . a:source
		endif

		for l:elem in l:first
			if !(type(l:elem) ==# s:t_string          &&
			 \   l:elem !=# ''                        &&
			 \   match(l:elem, '^[[:space:]]') ==# -1   )
				throw 'Commentable:INVALID SETTING:' . a:source
			endif
		endfor
	else
		"|===============================================|
		"| Wrong type for first                          |
		"|===============================================|
		throw 'Commentable:INVALID SETTING:' . a:source
	endif

	for l:elem in l:rest
		"|===============================================|
		"| Must be strings                               |
		"|===============================================|
		if type(l:elem) !=# s:t_string
			throw 'Commentable:INVALID SETTING:' . a:source
		endif
	endfor

	"|===============================================|
	"| Third element must have no trailing           |
	"|===============================================|
	if match(a:style[2], '[[:space:]]$') !=# -1
		throw 'Commentable:INVALID SETTING:' . a:source
	endif
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:PrepareStyle(style) abort {{{                                           |
"|                                                                           |
"| Convert a style for use by <SID>ReadStyle.                                |
"|                                                                           |
"| PARAMS:                                                                   |
"|   style) The style to convert. Must have been checked by                  |
"|          <SID>ValidateStyle.                                              |
"|                                                                           |
"| Returns the prepared style. The style will always:                        |
"| - Be a 4 list.                                                            |
"| - Where the first element is a 2 list of strings.                         |
"| - Where the second element of the first element begins '\V'.              |
"| - Where the remaining 3 elements are strings.                             |
"|===========================================================================|
function! s:PrepareStyle(style) abort
	let l:style = deepcopy(a:style)
	if len(l:style) ==# 3
		call add(l:style, ' ')
	endif

	if type(l:style[0]) ==# s:t_string
		let l:style[0] = [l:style[0], '\V' . l:style[0]]
	endif

	return l:style
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:ReadStyle(style) abort {{{                                              |
"|                                                                           |
"| Read the raw styles into internal format.                                 |
"|                                                                           |
"| PARAMS:                                                                   |
"|   style) The raw style to read.                                           |
"|                                                                           |
"| Returns a dict filled with the params for the style.                      |
"|===========================================================================|
function! s:ReadStyle(style) abort
	let l:ret = {}

	let l:ret.initial       = a:style[0][0]
	let l:ret.initial_regex = '\V' . a:style[0][1]
	let l:ret.medial        = a:style[1]
	let l:ret.final         = a:style[2]
	let l:ret.spacer        = a:style[3]

	return l:ret
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
