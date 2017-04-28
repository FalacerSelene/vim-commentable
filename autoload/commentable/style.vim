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
	 \ 'Refresh': function('<SID>Refresh'),
	 \ '_GetRawStyles': function('<SID>GetRawStyles'),
	 \ }

	call l:style._GetRawStyles()

	call <SID>ValidateStyle(l:style.raw_top, l:style.raw_top_source)
	let l:style.top = <SID>ReadStyle(l:style.raw_top)

	call <SID>ValidateStyle(l:style.raw_sub, l:style.raw_sub_source)
	let l:style.sub = <SID>ReadStyle(l:style.raw_sub)

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
	let l:self.top = <SID>ReadStyle(l:self.raw_top)

	call <SID>ValidateStyle(l:self.raw_sub, l:self.raw_sub_source)
	let l:self.sub = <SID>ReadStyle(l:self.raw_sub)
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
		let l:toplevel = commentable#GetVar('CommentableBlockStyle')
		let l:topsource = 'CommentableBlockStyle'
	catch /Commentable:NO VALUE:/
	endtry

	if !has_key(l:, 'topsource')
		let l:toplevel = <SID>StyleFromCommentString()
		let l:topsource = '&commentstring'
	endif

	try
		let l:substyle = commentable#GetVar('CommentableSubStyle')
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

	return [l:start, '', l:end]
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:ValidateStyle(style, source) abort {{{                                  |
"|                                                                           |
"| Assert that a style is valid input for <SID>ReadStyle.                    |
"|                                                                           |
"| PARAMS:                                                                   |
"|   style) The raw style to check.                                          |
"|   source) The source of the style. Used in error messages.                |
"|                                                                           |
"| Returns nothing. Throws if the style is not valid.                        |
"|===========================================================================|
function! s:ValidateStyle(style, source) abort
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
	return {}
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
