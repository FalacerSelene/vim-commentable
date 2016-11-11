"|===========================================================================|
"|                                                                           |
"|         FILE:  autoload/commentable/block.vim                             |
"|                                                                           |
"|  DESCRIPTION:  Block construction class.                                  |
"|                                                                           |
"|       AUTHOR:  @galtish                                                   |
"|      CONTACT:  < mj dot git plus commentable at fastmail dot com >        |
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

let g:commentable#block#lmat_none = 0 " Not part of a comment
let g:commentable#block#lmat_int  = 1 " Internal comment line
let g:commentable#block#lmat_wall = 2 " Wall of a comment

"|===========================================================================|
"|                               CONSTRUCTOR                                 |
"|===========================================================================|

"|===========================================================================|
"| commentable#block#New(indentamount) abort                             {{{ |
"|                                                                           |
"| Create a new block object. Only needs to know if it is indented or not;   |
"| the remaining parameters are determined in the constructor.               |
"|                                                                           |
"| PARAMS:                                                                   |
"|   indentamount) Is this an indented block?                                |
"|                                                                           |
"| Returns the block object.                                                 |
"|===========================================================================|
function! commentable#block#New(indentamount) abort
	return {
	 \ 'style': <SID>GetCommentStyle(a:indentamount > 0 ? 1 : 0),
	 \ 'paragraphs': [],
	 \ 'AddParagraph': function('<SID>AddParagraph'),
	 \ 'AddExisting': function('<SID>AddExisting'),
	 \ 'LineMatches': function('<SID>LineMatches'),
	 \ 'GetFormat': function('<SID>GetFormat'),
	 \ '_GetRange': function('<SID>GetRange'),
	 \ }
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"|                              PUBLIC METHODS                               |
"|===========================================================================|

"|===========================================================================|
"| block.AddParagraph(para) abort dict                                   {{{ |
"|                                                                           |
"| Add a new paragraph of text to this block.                                |
"|                                                                           |
"| PARAMS:                                                                   |
"|   para) The paragraph to add. Adds the exact object, not a copy.          |
"|                                                                           |
"| Returns nothing.                                                          |
"|===========================================================================|
function! s:AddParagraph(para) abort dict
	call add(l:self.paragraphs, a:para)
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| block.AddExisting(linenum) abort dict                                 {{{ |
"|                                                                           |
"| Add paragraphs from an existing block.                                    |
"|                                                                           |
"| PARAMS:                                                                   |
"|   linenum) A line in the exisiting paragraph. Will read forwards and      |
"|            backwards from this line to try to find the full paragraph.    |
"|                                                                           |
"| Returns [firstline, lastline], showing which lines were used. Throws if   |
"| the given line is not in the paragraph.                                   |
"|===========================================================================|
function! s:AddExisting(linenum) abort dict
	let [l:firstline, l:lastline] = l:self._GetRange(a:linenum)

	let l:lines = getline(l:firstline, l:lastline)
	call map(l:lines, 'commentable#StripSpaces(v:val)')
	call map(l:lines, 'substitute(v:val, ''\V\^' . l:self.style[0] . ''', "", "")')
	call map(l:lines, 'substitute(v:val, ''\V' . l:self.style[2] . '\$'', "", "")')

	if match(l:lines[0], '\V\^' . l:self.style[1] . '\*\$') == 0
		call remove(l:lines, 0)
	endif

	if len(l:lines) > 0                                           &&
	 \ match(l:lines[-1], '\V\^' . l:self.style[1] . '\*\$') == 0
		call remove(l:lines, -1)
	endif

	call map(l:lines,
	 \       'substitute(v:val, ''\V\^' . l:self.style[1] . ''', "", "")')

	if l:self.style[3] !=# ''
		call map(l:lines,
		 \       'substitute(v:val, ''\V\^' . l:self.style[3] . ''', "", "")')
		call map(l:lines,
		 \       'substitute(v:val, ''\V' . l:self.style[3] . '\$'', "", "")')
	endif

	if len(l:lines) == 0
		call l:self.AddParagraph(commentable#paragraph#New(''))
	else
		let l:curpar = commentable#paragraph#New(l:lines[0])
		let l:lastlineblank = 0
		for l:line in l:lines[1:]
			if l:line =~# '\m^\s*$'
				call l:self.AddParagraph(l:curpar)
				let l:curpar = commentable#paragraph#New(l:line)
				let l:lastlineblank = 1
			elseif l:curpar.IsInParagraph(l:line) && (!l:lastlineblank)
				call l:curpar.AddLine(l:line)
			else
				call l:self.AddParagraph(l:curpar)
				let l:curpar = commentable#paragraph#New(l:line)
				let l:lastlineblank = 0
			endif
		endfor
		call l:self.AddParagraph(l:curpar)
	endif

	return [l:firstline, l:lastline]
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| block.LineMatches(linenum) abort dict                                 {{{ |
"|                                                                           |
"| Determine if a given existing line is valid for this block.               |
"|                                                                           |
"| PARAMS:                                                                   |
"|   linenum) The line to verify.                                            |
"|                                                                           |
"| Returns a commentable#block#lmat value.                                   |
"|===========================================================================|
function! s:LineMatches(linenum) abort dict
	let l:text = getline(a:linenum)
	let l:text = substitute(l:text, '\m^\s*', '', '')
	let l:text = substitute(l:text, '\m\s*$', '', '')

	let l:iscomment = g:commentable#block#lmat_none

	if (match(l:text, '\V' . l:self.style[0]) == 0)      ||
	 \ ((l:self.style[2] !=# '')                       &&
	 \  (strlen(l:text) >= strlen(l:self.style[2]))    &&
	 \  (match(l:text, '\V' . l:self.style[2])
	 \   == strlen(l:text) - strlen(l:self.style[2])))   ||
	 \ ((l:self.style[1] !=# '')                       &&
	 \  (a:linenum > 1)                                &&
	 \  (strlen(l:text) >= strlen(l:self.style[1]))    &&
	 \  (match(l:text, '\V' . l:self.style[1]) == 0)   &&
	 \  (l:self.LineMatches(a:linenum - 1)))
		let l:iscomment = g:commentable#block#lmat_int
	endif

	"|===============================================|
	"| We know this is a line, check if it's a wall. |
	"|===============================================|
	if l:iscomment == g:commentable#block#lmat_int         &&
	 \ match(l:text, '\V\^' . l:self.style[0]
	 \                      . l:self.style[1] . '\*'
	 \                      . l:self.style[2] . '\$') == 0
		let l:iscomment = g:commentable#block#lmat_wall
	endif

	return l:iscomment
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| block.GetFormat(width) abort dict                                     {{{ |
"|                                                                           |
"| PARAMS:                                                                   |
"|   width) The required length of the lines to be output.                   |
"|                                                                           |
"| Returns a list of lines of the requested length comprising the block.     |
"|===========================================================================|
function! s:GetFormat(width) abort dict
	let l:textlen = a:width
	 \            - strlen(l:self.style[0])
	 \            - strlen(l:self.style[2])
	 \            - (2 * strlen(l:self.style[3]))

	let l:lines = []
	for l:para in l:self.paragraphs
		call extend(l:lines, l:para.GetFormat(l:textlen))
	endfor

	if l:self.style[3] !=# ''
		call map(l:lines, 'l:self.style[3] . v:val . l:self.style[3]')
	endif

	call map(l:lines, 'l:self.style[0] . v:val . l:self.style[2]')

	if l:self.style[1] !=# ''
		let l:wall = l:self.style[0]
		\         . strpart(repeat(l:self.style[1], a:width),
		\                   0,
		\                   a:width - strlen(l:self.style[0])
		\                           - strlen(l:self.style[2]))
		\         . l:self.style[2]
		call insert(l:lines, l:wall)
		call add(l:lines, l:wall)
	endif

	return l:lines
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"|                              PRIVATE METHODS                              |
"|===========================================================================|

"|===========================================================================|
"| block._GetRange(linenum) abort dict                                   {{{ |
"|                                                                           |
"| Get block range around a given line.                                      |
"|                                                                           |
"| PARAMS:                                                                   |
"|   linenum) The line around which to get the range.                        |
"|                                                                           |
"| Returns the 2list [l:first, l:last] of the range. If the specified line   |
"| is not part of a block, throws.                                           |
"|===========================================================================|
function! s:GetRange(linenum) abort dict
	let l:startlinematch = l:self.LineMatches(a:linenum)
	if l:startlinematch == g:commentable#block#lmat_none
		throw 'Commentable:NOT A COMMENT:Line ' . a:linenum
	endif

	let l:firstline = a:linenum
	let l:lastline = a:linenum
	let l:buflastline = line('$')

	if l:startlinematch == g:commentable#block#lmat_int
		"|===============================================|
		"| Internal line, look back and forth to find    |
		"| the walls.                                    |
		"|===============================================|
		while l:firstline > 1
			let l:abovematch = l:self.LineMatches(l:firstline - 1)

			if l:abovematch == g:commentable#block#lmat_none
				break
			elseif l:abovematch == g:commentable#block#lmat_wall
				let l:firstline -= 1
				break
			else
				let l:firstline -= 1
			endif
		endwhile

		while l:lastline < l:buflastline
			let l:belowmatch = l:self.LineMatches(l:lastline + 1)

			if l:belowmatch == g:commentable#block#lmat_none
				break
			elseif l:belowmatch == g:commentable#block#lmat_wall
				let l:lastline += 1
				break
			else
				let l:lastline += 1
			endif
		endwhile
	elseif l:startlinematch == g:commentable#block#lmat_wall
		"|===============================================|
		"| Wall, look before and after to find which way |
		"| to go. 0 = up, 1 = down.                      |
		"|===============================================|
		let l:goingdown =
		 \ (l:lastline == l:buflastline       ||
		 \  l:self.LineMatches(l:lastline + 1)
		 \  == g:commentable#block#lmat_none    )
		 \ ? 0
		 \ : 1

		if l:goingdown
			while l:lastline < l:buflastline
				let l:belowmatch = l:self.LineMatches(l:lastline + 1)

				if l:belowmatch == g:commentable#block#lmat_none
					break
				elseif l:belowmatch == g:commentable#block#lmat_wall
					let l:lastline += 1
					break
				else
					let l:lastline += 1
				endif
			endwhile
		else
			while l:firstline > 1
				let l:abovematch = l:self.LineMatches(l:firstline - 1)

				if l:abovematch == g:commentable#block#lmat_none
					break
				elseif l:abovematch == g:commentable#block#lmat_wall
					let l:firstline -= 1
					break
				else
					let l:firstline -= 1
				endif
			endwhile
		endif
	endif

	return [l:firstline, l:lastline]
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"|                             PRIVATE FUNCTIONS                             |
"|===========================================================================|

"|===========================================================================|
"| s:GetCommentStyle(isindented) abort                                   {{{ |
"|                                                                           |
"| Get the current comment style, and ensure that it is valid. A valid style |
"| must:                                                                     |
"| - Be a list.                                                              |
"| - Be 3 or 4 items long.                                                   |
"| - Contain only strings.                                                   |
"| - Have no leading whitespace in the initial item.                         |
"| - Have no trailing whitespace in the third item.                          |
"|                                                                           |
"| PARAMS:                                                                   |
"|   isindented) If this is true, then will first check and attempt to       |
"|               return the sub-style.                                       |
"|                                                                           |
"| Returns the configured style. Throws if the style is invalid.             |
"|===========================================================================|
function! s:GetCommentStyle(isindented) abort
	"|===============================================|
	"| Get the style. If we're indented, try the     |
	"| substyle first.                               |
	"|===============================================|
	if a:isindented
		try
			let l:style = commentable#GetVar('CommentableSubStyle')
			let l:using_var = 'CommentableSubStyle'
		catch /Commentable:NO VALUE:/
		endtry
	endif

	if !has_key(l:, 'style')
		try
			let l:style = commentable#GetVar('CommentableBlockStyle')
			let l:using_var = 'CommentableBlockStyle'
		catch /Commentable:NO VALUE:/
		endtry
	endif

	if !has_key(l:, 'style')
		let l:style = <SID>StyleFromCommentString()
		let l:using_var = '&commentstring'
	endif

	"|===============================================|
	"| Now we have a style - validate it.            |
	"|===============================================|
	if type(l:style) !=# s:t_list                   ||
	 \ ( len(l:style) !=# 3 && len(l:style) !=# 4 ) ||
	 \ l:style[0]    ==# ''
		throw 'Commentable:INVALID SETTING:' . l:using_var
	else
		for l:elem in l:style
			if type(l:elem) !=# s:t_string
				throw 'Commentable:INVALID SETTING:' . l:using_var
			endif
		endfor

		if l:style[0] =~# '\m^[[:space:]]' ||
		 \ l:style[2] =~# '\m[[:space:]]$'
			throw 'Commentable:INVALID SETTING:' . l:using_var
		endif
	endif

	"|===============================================|
	"| All valid. If there is no textlead, add as a  |
	"| single space.                                 |
	"|===============================================|
	let l:retstyle = copy(l:style)
	if len(l:retstyle) ==# 3
		call add(l:retstyle, ' ')
	endif

	return l:retstyle
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:StyleFromCommentString() abort                                      {{{ |
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
