"|===========================================================================|
"| File:        commentable.vim (autoload)                                   |
"| Description: Adds utilities for block-commenting.                         |
"| Author:      @galtish < mj dot git plus commentable at fastmail dot com > |
"| Licence:     See LICENCE.md                                               |
"| Version:     See plugin/commentable.vim                                   |
"|===========================================================================|

"|===========================================================================|
"| commentable#IsCommentBlock(lineno) abort                                  |
"|===========================================================================|
function! commentable#IsCommentBlock(lineno) abort
	throw 'Commentable:NOT YET IMPLEMENTED:IsCommentBlock'
endfunction
"|===========================================================================|
"| commentable#Reformat(lineno) abort                                        |
"|===========================================================================|
function! commentable#Reformat(lineno) abort
	throw 'Commentable:NOT YET IMPLEMENTED:Reformat'
endfunction
"|===========================================================================|
"| commentable#CreateBlock(first, last) abort                                |
"|===========================================================================|
function! commentable#CreateBlock(first, last) abort
	throw 'Commentable:NOT YET IMPLEMENTED:CreateBlock'
endfunction

"|===========================================================================|
"| Version checking                                                          |
"|===========================================================================|
let s:has_t_number = exists('v:t_number')

"|===========================================================================|
"| s:GetVar(varname) abort                                               {{{ |
"|===========================================================================|
function! s:GetVar(varname) abort
	if exists('b:' . a:varname)
		return eval('b:' . a:varname)
	elseif exists('g:' . a:varname)
		return eval('g:' . a:varname)
	else
		throw 'Commentable:NO VALUE:' . a:varname
	endif
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
"| s:GetCommentStyle(is_indented) abort                                  {{{ |
"|===========================================================================|
function! s:GetCommentStyle(is_indented) abort
	"|===============================================|
	"| Get the style. If we're indented, try the     |
	"| substyle first.                               |
	"|===============================================|
	if a:is_indented
		try
			let l:style = <SID>GetVar('CommentableSubStyle')
			let l:using_var = 'CommentableSubStyle'
		catch /Commentable:NO VALUE:/
		endtry
	endif

	if ! exists('l:style')
		let l:style = <SID>GetVar('CommentableBlockStyle')
		let l:using_var = 'CommentableBlockStyle'
	endif

	"|===============================================|
	"| Now we have a style - validate it.            |
	"|===============================================|
	if type(l:style) !=# s:has_t_number ? v:t_list : type([]) ||
	 \ len(l:style) !=# 3 ||
	 \ l:style[0] ==# ''
		throw 'Commentable:INVALID SETTING:' . l:using_var
	else
		let l:elem = ''
		for l:elem in l:style
			if type(l:elem) !=# s:has_t_number ? v:t_string : type('') ||
			 \ l:elem =~# '\m\_s'
				throw 'Commentable:INVALID SETTING:' . l:using_var
			endif
		endfor
	endif

	"|===============================================|
	"| All valid                                     |
	"|===============================================|
	return l:style
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
"| s:GetCommentBlockWidth(amount_indented) abort                         {{{ |
"|===========================================================================|
function! s:GetCommentBlockWidth(amount_indented) abort
	let l:is_indented = a:amount_indented !=# 0

	"|===============================================|
	"| Get the width.                                |
	"|===============================================|
	if l:is_indented
		try
			let l:width = <SID>GetVar('CommentableSubWidth')
			let l:width_var = 'CommentableSubWidth'
		catch /Commentable:NO VALUE:/
		endtry
	endif

	if ! exists('l:width')
		try
			let l:width = <SID>GetVar('CommentableBlockWidth')
			let l:width_var = 'CommentableBlockWidth'
		catch /Commentable:NO VALUE:/
		endtry
	endif

	"|===============================================|
	"| Get the column. Fallback to textwidth.        |
	"|===============================================|
	if l:is_indented
		try
			let l:column = <SID>GetVar('CommentableSubColumn')
			let l:column_var = 'CommentableSubColumn'
		catch /Commentable:NO VALUE:/
		endtry
	endif

	if ! exists('l:column')
		try
			let l:column = <SID>GetVar('CommentableBlockColumn')
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
			if type(l:elem) !=# s:has_t_number ? v:t_number : type(1) ||
			 \ l:elem <= 0
				throw 'Commentable:INVALID SETTING:' . eval(l:var_n)
			endif
		endif
	endfor

	"|===============================================|
	"| Now find the minimun block width.             |
	"|===============================================|
	let l:min = l:column
	if exists('l:width')
		let l:min = min([l:min, a:amount_indented + l:width])
	endif

	return l:min
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
"| s:GetInternalWidth(style, block_width) abort                          {{{ |
"|===========================================================================|
function! s:GetInternalWidth(style, block_width) abort
	let l:internal_width  = a:block_width
	let l:internal_width -= strdisplaywidth(a:style[0])
	let l:internal_width -= strdisplaywidth(a:style[2])
	return max([0, l:internal_width])
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
"| s:GetPreserveList() abort                                             {{{ |
"|===========================================================================|
function! s:GetPreserveList() abort
	let l:ret = []
	for [l:name, l:default] in [
	 \   ['CommentableParaBefore', []],
	 \   ['CommentableParaAfter', []],
	 \   ['CommentableParaBoth', ['\m^\s*$']],
	 \ ]
		try
			let l:val = <SID>GetVar(l:name)
		catch /Commentable:NO VALUE:/
			let l:val = l:default
		endtry

		if type(l:val) !=# s:has_t_number ? v:t_list : type([])
			throw 'Commentable:INVALID SETTING:' . l:name
		else
			for l:elem in l:val
				if type(l:elem) !=# s:has_t_number ? v:t_string : type('')
					throw 'Commentable:INVALID SETTING:' . l:name
				endif
			endfor
		endif
		call add(l:ret, l:val)
	endfor

	return l:ret
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
"| s:PadRight(text, reqlength, padding) abort                            {{{ |
"|===========================================================================|
function! s:PadRight(text, reqlength, padding) abort
	let l:textlength = strdisplaywidth(a:text)
	let l:fillerlength = strdisplaywidth(a:padding)

	if a:padding ==# '' || l:textlength >= a:reqlength
		return a:text
	endif

	let l:text = a:text
	while l:textlength < a:reqlength
		let l:text .= a:padding
		let l:textlength += l:fillerlength
	endwhile

	return l:text[:(a:reqlength - 1)]
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
"| s:GetTempRegs() abort                                                 {{{ |
"|===========================================================================|
function! s:GetTempRegs() abort
	return [@-,@0,@1,@2,@3,@4,@5,@6,@7,@8,@9,@"]
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
"| s:RestoreTempRegs(saved) abort                                        {{{ |
"|===========================================================================|
function! s:RestoreTempRegs(saved) abort
	let [@-,@0,@1,@2,@3,@4,@5,@6,@7,@8,@9,@"] = a:saved
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

