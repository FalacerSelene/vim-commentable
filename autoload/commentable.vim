"|===========================================================================|
"| File:        commentable.vim (autoload)                                   |
"| Description: Adds utilities for block-commenting.                         |
"| Author:      @galtish < mj dot git plus commentable at fastmail dot com > |
"| Licence:     See LICENCE.md                                               |
"| Version:     See plugin/commentable.vim                                   |
"|===========================================================================|

"|===========================================================================|
"| commentable#IsCommentBlock(lineno) abort                                  |
"|                                                                           |
"| Exposed wrapper around s:IsCommentBlock.                                  |
"|                                                                           |
"| Returns true/false.                                                       |
"|===========================================================================|
function! commentable#IsCommentBlock(lineno) abort
	let l:style = <SID>GetCommentStyle(indent(a:lineno) > 0)
	return <SID>IsCommentBlock(a:lineno, l:style)
endfunction

"|===========================================================================|
"| commentable#Reformat(lineno) abort                                        |
"|===========================================================================|
function! commentable#Reformat(lineno) abort
	let l:indent = indent(a:lineno)
	let l:indentchars = substitute(getline(a:lineno), '\m^\(\s*\).*', '\1', '')
	let l:style = <SID>GetCommentStyle(l:indent > 0)
	let l:blockwidth = <SID>GetCommentBlockWidth(l:indent)
	let l:textwidth = <SID>GetInternalWidth(l:style, l:blockwidth)
	let l:preservelist = <SID>GetPreserveList()

	let [l:startline, l:endline] = <SID>GetBlockRange(a:lineno, l:style)

	if l:startline == 0 && l:endline == 0
		return
	endif

	let l:lines = <SID>GetBlockContents(a:lineno, l:style)
	let l:lines = <SID>LinesToParagraphs(l:lines, l:preservelist)
	let l:lines = <SID>ReflowParagraphs(l:lines, l:textwidth)
	let l:lines = <SID>CreateBlock(l:lines, l:style, l:textwidth, l:indentchars)

	execute l:startline . ',' . l:endline . 'call <SID>ReplaceLines(l:lines)'
endfunction

"|===========================================================================|
"| commentable#CreateBlock() abort range                                     |
"|===========================================================================|
function! commentable#CreateBlock() abort range
	let l:indent = indent(a:firstline)
	let l:indentchars = substitute(getline(a:firstline), '\m^\(\s*\).*', '\1', '')
	let l:style = <SID>GetCommentStyle(l:indent > 0)
	let l:blockwidth = <SID>GetCommentBlockWidth(l:indent)
	let l:textwidth = <SID>GetInternalWidth(l:style, l:blockwidth)
	let l:preservelist = <SID>GetPreserveList()

	let l:lines = []
	for l:lineno in range(a:firstline, a:lastline)
		call add(l:lines, <SID>GetLineText(l:lineno, l:style))
	endfor

	let l:lines = <SID>LinesToParagraphs(l:lines, l:preservelist)
	let l:lines = <SID>ReflowParagraphs(l:lines, l:textwidth)
	let l:lines = <SID>CreateBlock(l:lines, l:style, l:textwidth, l:indentchars)

	"|===============================================|
	"| Changes occur after this point.               |
	"|===============================================|
	execute a:firstline . ',' . a:lastline . 'call <SID>ReplaceLines(l:lines)'
endfunction

"|===========================================================================|
"| Version checking                                                          |
"|===========================================================================|
let s:has_t_number = exists('v:t_number')

"|===========================================================================|
"| s:IsCommentBlock(lineno, style) abort                                 {{{ |
"|                                                                           |
"| Indicates if the line specified is a comment according to the set style   |
"|                                                                           |
"| We are delibarately liberal with what counts as a comment for this        |
"| function. A comment is any line whose text, after stripping leading and   |
"| trailing whitespace, either:                                              |
"| 1) Begins with the opener from the current style,                         |
"| 2) Ends with the non-null finisher from the current style,                |
"| 3) Begins with the non-null medial from the current style, and            |
"|    immediately follows a line which also counts as a comment.             |
"|                                                                           |
"| Returns true/false.                                                       |
"|===========================================================================|
function! s:IsCommentBlock(lineno, style) abort
	let l:linetext = substitute(getline(a:lineno),
	 \                          '\m^\s*\(.\{-}\)\s*$',
	 \                          '\1',
	 \                          '')
	let l:linelength = strlen(l:linetext)
	let [l:opener, l:medial, l:finisher] = a:style

	if match(l:linetext, '\V' . l:opener) == 0
		"|===============================================|
		"| Line starts with the correct opener           |
		"|===============================================|
		return 1
	elseif ((l:finisher !=# '') &&
	 \      (strlen(l:linetext) >= strlen(l:finisher)) &&
	 \      (match(l:linetext, '\V' . l:finisher)
	 \       == l:linelength - len(l:finisher)))
		"|===============================================|
		"| Line terminaties with the correct finisher    |
		"|===============================================|
		return 2
	elseif ((l:medial !=# '') &&
	 \      (a:lineno > 1) &&
	 \      (strlen(l:linetext) >= strlen(l:medial)) &&
	 \      (match(l:linetext, '\V' . l:medial) == 0) &&
	 \      (<SID>IsCommentBlock(a:lineno - 1, a:style)))
		"|===============================================|
		"| Line start with a medial and follows another  |
		"| comment line                                  |
		"|===============================================|
		return 3
	else
		"|===============================================|
		"| Line is no comment                            |
		"|===============================================|
		return 0
	endif
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

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
	if type(l:style) !=# (s:has_t_number ? v:t_list : type([])) ||
	 \ len(l:style) !=# 3 ||
	 \ l:style[0] ==# ''
		throw 'Commentable:INVALID SETTING:' . l:using_var
	else
		let l:elem = ''
		for l:elem in l:style
			if type(l:elem) !=# (s:has_t_number ? v:t_string : type('')) ||
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
			if type(l:elem) !=# (s:has_t_number ? v:t_number : type(1)) ||
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
"| s:GetInternalWidth(style, block_width) abort                          {{{ |
"|===========================================================================|
function! s:GetInternalWidth(style, block_width) abort
	let l:internal_width  = a:block_width
	let l:internal_width -= strlen(a:style[0]) + 1
	let l:final_len = strlen(a:style[2])
	if l:final_len != 0
		let l:internal_width -= (strlen(a:style[2]) + 1)
	endif
	return max([0, l:internal_width])
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

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

		if type(l:val) !=# (s:has_t_number ? v:t_list : type([]))
			throw 'Commentable:INVALID SETTING:' . l:name
		else
			for l:elem in l:val
				if type(l:elem) !=# (s:has_t_number ? v:t_string : type(''))
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

"|===========================================================================|
"| s:PadRight(text, reqlength, padding) abort                            {{{ |
"|===========================================================================|
function! s:PadRight(text, reqlength, padding) abort
	let l:textlength = strlen(a:text)
	let l:fillerlength = strlen(a:padding)

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

"|===========================================================================|
"| s:GetTempRegs() abort                                                 {{{ |
"|===========================================================================|
function! s:GetTempRegs() abort
	return [@-,@0,@1,@2,@3,@4,@5,@6,@7,@8,@9,@"]
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:RestoreTempRegs(saved) abort                                        {{{ |
"|===========================================================================|
function! s:RestoreTempRegs(saved) abort
	let [@-,@0,@1,@2,@3,@4,@5,@6,@7,@8,@9,@"] = a:saved
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:GetPreserve(linetext, preservelist) abort                           {{{ |
"|                                                                           |
"| Returns the preservation state of a line w.r.t. paragraphs after          |
"| reflowing.                                                                |
"|                                                                           |
"| Returns 0 for no preservation, 1 for break paragraph before, 2 for break  |
"| paragraph after, 3 for break paragraph before and after.                  |
"|===========================================================================|
function! s:GetPreserve(linetext, preservelist) abort
	let [l:before, l:after, l:both] = a:preservelist

	for l:pat in l:both
		if match(a:linetext, l:pat) != -1
			return 3
		endif
	endfor

	for l:pat in l:before
		if match(a:linetext, l:pat) != -1
			return 1
		endif
	endfor

	for l:pat in l:after
		if match(a:linetext, l:pat) != -1
			return 2
		endif
	endfor

	return 0
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:LinesToParagraphs(lines, preservelist) abort                        {{{ |
"|                                                                           |
"| Collapse lines of text into a list of paragraphs. Uses the preserve list  |
"| to moderate where paragraphs should start and end.                        |
"|===========================================================================|
function! s:LinesToParagraphs(lines, preservelist) abort
	if len(a:lines) == 0
		"|===============================================|
		"| If starting as an empty list, just return it  |
		"|===============================================|
		return a:lines
	endif

	let l:lines = copy(a:lines)
	let l:paragraphs = []
	let l:curparagraph = ''

	while len(l:lines) != 0
		let l:thisline = l:lines[0]
		call remove(l:lines, 0)

		let l:preserve = <SID>GetPreserve(l:thisline, a:preservelist)

		if l:preserve == 1
			"|===============================================|
			"| This line must start the paragraph            |
			"|===============================================|
			if l:curparagraph ==# ''
				let l:curparagraph = l:thisline
			else
				call add(l:paragraphs, l:curparagraph)
				let l:curparagraph = l:thisline
			endif
		elseif l:preserve == 2
			"|===============================================|
			"| This line must end the paragraph              |
			"|===============================================|
			if l:curparagraph ==# ''
				call add(l:paragraphs, l:thisline)
			else
				if l:thisline ==# ''
					let l:toadd = ''
				else
					let l:toadd = ' ' . l:thisline
				endif
				call add(l:paragraphs, l:curparagraph . l:toadd)
				let l:curparagraph = ''
			endif
		elseif l:preserve == 3
			"|===============================================|
			"| This line is a paragraph all of its own.      |
			"|===============================================|
			if l:curparagraph ==# ''
				call add(l:paragraphs, l:thisline)
			else
				call add(l:paragraphs, l:curparagraph)
				call add(l:paragraphs, l:thisline)
				let l:curparagraph = ''
			endif
		else
			"|===============================================|
			"| Append this line to the current paragraph     |
			"|===============================================|
			if l:curparagraph ==# ''
				let l:curparagraph = l:thisline
			else
				if l:thisline ==# ''
					let l:toadd = ''
				else
					let l:toadd = ' ' . l:thisline
				endif
				let l:curparagraph .= l:toadd
			endif
		endif
	endwhile

	"|===============================================|
	"| Add the last paragraph                        |
	"|===============================================|
	call add(l:paragraphs, l:curparagraph)

	"|===============================================|
	"| Strip leading blank paragraphs                |
	"|===============================================|
	while len(l:paragraphs) && l:paragraphs[0] ==# ''
		call remove(l:paragraphs, 0)
	endwhile

	"|===============================================|
	"| Strip trailing blank paragraphs               |
	"|===============================================|
	while len(l:paragraphs) && l:paragraphs[-1] ==# ''
		call remove(l:paragraphs, -1)
	endwhile

	if len(l:paragraphs) == 0
		let l:paragraphs = ['']
	endif

	return l:paragraphs
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:IsCommentWall(lineno, style) abort                                  {{{ |
"|                                                                           |
"| Indicates if the line specified is comment wall according to the passed   |
"| in style.                                                                 |
"|                                                                           |
"| Returns 1 if the line is a wall, else 0.                                  |
"|===========================================================================|
function! s:IsCommentWall(lineno, style) abort
	let l:linetext = substitute(getline(a:lineno),
	 \                          '\m^\s*\(.\{-}\)\s*$',
	 \                          '\1',
	 \                          '')
	let l:opener = a:style[0]
	let l:medial = a:style[1]
	let l:finisher = a:style[2]
	let l:linelength = strlen(l:linetext)

	if l:finisher !=# ''
		"|===============================================|
		"| Remove finisher                               |
		"|===============================================|
		if (match(l:linetext, '\V' . l:finisher)
		 \  == l:linelength - strlen(l:finisher))
			let l:linetext =
			 \  l:linetext[0:l:linelength - strlen(l:finisher) - 1]
		else
			return 0
		endif
	endif

	"|===============================================|
	"| Remove opener                                 |
	"|===============================================|
	if l:linetext[0:strlen(l:opener) - 1] ==# l:opener
		let l:linetext = l:linetext[strlen(l:opener):]
	else
		return 0
	endif

	"|===============================================|
	"| Remove medials                                |
	"|===============================================|
	let l:medlen = strlen(l:medial)
	while l:linetext !=# ''
		if l:medlen > strlen(l:linetext)
			let l:complen = strlen(l:linetext)
		else
			let l:complen = l:medlen
		endif

		if l:linetext[0:l:complen - 1] ==# l:medial[0:l:complen - 1]
			let l:linetext = l:linetext[(l:complen):]
		else
			break
		endif
	endwhile

	if l:linetext ==# ''
		return 1
	else
		return 0
	endif
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:GetLineText(lineno, style) abort                                    {{{ |
"|                                                                           |
"| Get the text from a given lineno, after de-commenting it according to the |
"| given style. Returns the text, which may be null.                         |
"|===========================================================================|
function! s:GetLineText(lineno, style) abort
	let [l:opener, l:medial, l:finisher] = a:style
	let l:text = getline(a:lineno)

	"|===============================================|
	"| Strip leading and trailing whitespace         |
	"|===============================================|
	let l:text = substitute(l:text, '\m^\s*\(.\{-}\)\s*$', '\1', '')

	if match(l:text, '\V' . l:opener) == 0
		"|===============================================|
		"| Remove opener                                 |
		"|===============================================|
		let l:text = l:text[strlen(l:opener):]
	endif

	if match(l:text, '\V' . l:finisher) == strlen(l:text) - strlen(l:finisher)
		"|===============================================|
		"| Remove finisher                               |
		"|===============================================|
		let l:text = l:text[:(0 - 1 - strlen(l:finisher))]
	endif

	"|===============================================|
	"| Remove medial elements                        |
	"|===============================================|
	while l:text[:(strlen(l:medial) - 1)] == l:medial
		let l:text = l:text[strlen(l:medial):]
	endwhile

	"|===============================================|
	"| Strip leading and trailing again              |
	"|===============================================|
	let l:text = substitute(l:text, '\m^\s*\(.\{-}\)\s*$', '\1', '')

	return l:text
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:GetBlockRange(lineno, style) abort                                  {{{ |
"|                                                                           |
"| Get the total range of the block comment containing the specified lineno. |
"| Returns a 2list, [startline, endline]. If the initially specified line is |
"| not a comment, returns [0,0].                                             |
"|===========================================================================|
function! s:GetBlockRange(lineno, style) abort
	if <SID>IsCommentBlock(a:lineno) == 0
		return [0, 0]
	endif

	let l:startline = a:lineno
	let l:endline = a:lineno

	while <SID>IsCommentBlock(l:startline - 1) != 0 &&
	 \    l:startline > 1
		let l:startline -= 1
		if <SID>IsCommentWall(l:startline, a:style)
			break
		endif
	endwhile

	while <SID>IsCommentBlock(l:endline + 1) != 0 &&
	 \    l:endline < line('$')
		let l:endline += 1
		if <SID>IsCommentWall(l:endline, a:style)
			break
		endif
	endwhile

	return [l:startline, l:endline]
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:GetBlockContents(lineno, style) abort                               {{{ |
"|                                                                           |
"| Get the contents of a block comment surrounding the given lineno, using   |
"| the given style.                                                          |
"|                                                                           |
"| Returns a list of the text of each line in the block.                     |
"|===========================================================================|
function! s:GetBlockContents(lineno, style) abort
	let [l:startline, l:endline] = <SID>GetBlockRange(a:lineno, a:style)
	if l:startline == 0
		return []
	endif

	if <SID>IsCommentWall(l:startline, a:style)
		let l:startline += 1
	endif

	if <SID>IsCommentWall(l:endline, a:style)
		let l:endline -= 1
	endif

	if l:endline < l:startline
		return []
	endif

	let l:lines = []
	for l:num in range(l:startline, l:endline)
		call add(l:lines, <SID>GetLineText(l:num, a:style))
	endfor

	return l:lines
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:ReflowParagraphs(paras, width) abort                                {{{ |
"|                                                                           |
"| Reflow paragraphs into a list of lines, none of with is greater than the  |
"| given width. Splits paragraphs at as close to width as possible without   |
"| breaking words.                                                           |
"|===========================================================================|
function! s:ReflowParagraphs(paras, width) abort
	let l:lines = []

	for l:para in a:paras
		while strlen(l:para) > a:width
			"|===============================================|
			"| Chop width off and add to line                |
			"|===============================================|
			let l:lastspace = 0
			for l:idx in range(0, a:width)
				if l:para[l:idx] ==# ' '
					let l:lastspace = l:idx
				endif
			endfor

			if l:lastspace == 0
				"|===============================================|
				"| Ok, I guess just break on first space?        |
				"|===============================================|
				let l:lastspace = match(l:para, ' ')
				if l:lastspace == -1
					"|===============================================|
					"| No spaces at all in this line...              |
					"|===============================================|
					break
				endif
			endif

			"|===============================================|
			"| Add the line, cut down to size.               |
			"|===============================================|
			call add(l:lines, l:para[:(l:lastspace - 1)])
			let l:para = l:para[(l:lastspace + 1):]
		endwhile

		"|===============================================|
		"| Add last line in paragraph.                   |
		"|===============================================|
		call add(l:lines, l:para)
	endfor

	return l:lines
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:CreateBlock(lines, style, commentwidth, indentchars) abort          {{{ |
"|                                                                           |
"| Creates a list of lines which form a block comment from the given text.   |
"|                                                                           |
"| Returns the list of lines, ready to output.                               |
"|===========================================================================|
function! s:CreateBlock(lines, style, commentwidth, indentchars) abort
	let l:comment = []
	let [l:opener, l:medial, l:finisher] = a:style

	if l:medial !=# ''
		let l:midchars = repeat(l:medial,
		 \                      ((a:commentwidth + 2) / strlen(l:medial)) + 1)
		if l:finisher ==# ''
			let l:midchars = l:midchars[0:(a:commentwidth)]
		else
			let l:midchars = l:midchars[0:(a:commentwidth + 1)]
		endif
		let l:wall = a:indentchars . l:opener . l:midchars . l:finisher
		unlet l:midchars

		call add(l:comment, l:wall)
	endif

	for l:line in a:lines
		let l:outline = a:indentchars . l:opener . ' ' .
		 \              <SID>PadRight(l:line, a:commentwidth, ' ')

		if l:finisher !=# ''
			let l:outline .= ' ' . l:finisher
		endif

		call add(l:comment, l:outline)
	endfor

	if l:medial !=# ''
		call add(l:comment, l:wall)
	endif

	return l:comment
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:ReplaceLines(with) abort range                                      {{{ |
"|                                                                           |
"| Replaces lines in range with lines given as 'with'.                       |
"|                                                                           |
"| This function inherantly has side-effects! But tries to keep them at a    |
"| minimum.                                                                  |
"|===========================================================================|
function! s:ReplaceLines(with) abort range
	let l:savedreg = <SID>GetTempRegs()
	let l:cursorpos = getcurpos()
	keepmarks execute a:firstline . ',' . a:lastline . 'delete _'
	call append(a:firstline - 1, a:with)
	call setpos('.', l:cursorpos)
	call <SID>RestoreTempRegs(l:savedreg)
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
