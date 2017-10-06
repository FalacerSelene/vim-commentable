"|===========================================================================|
"|                                                                           |
"|         FILE:  autoload/commentable.vim                                   |
"|                                                                           |
"|  DESCRIPTION:  Primary autoload functions for plugin.                     |
"|                See plugin/commentable.vim for more details.               |
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
	return commentable#block#IsComment(a:lineno)
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| commentable#Reformat() abort range {{{                                    |
"|                                                                           |
"| Reformat the comment block on the given lines. Reformatting includes:     |
"| - Aligning all the lines.                                                 |
"| - Setting the line length to be correct.                                  |
"| - Ensuring that all the text flows correctly from one line to the next.   |
"| - Conforming to paragraph configuration.                                  |
"|                                                                           |
"| PARAMS: NONE                                                              |
"|                                                                           |
"| Returns nothing. May throw.                                               |
"|===========================================================================|
function! commentable#Reformat() abort range
	"|===============================================|
	"| Get all paragraphs in range                   |
	"|===============================================|
	let l:blockpattern = <SID>GetExistingPattern(a:firstline, a:lastline)

	"|===============================================|
	"| Starting at the end, reformat all the blocks  |
	"| in range                                      |
	"|===============================================|
	for l:elem in reverse(l:blockpattern)
		if l:elem[0] !=# 'block'
			continue
		endif

		let l:at_line = (l:elem[1] < a:firstline ? a:firstline : l:elem[1])

		let l:indent = indent(l:at_line)
		let l:indent_chars =
		 \  substitute(getline(l:at_line), '\m^\(\s*\).*', '\1', '')
		let l:block_width = <SID>GetCommentBlockWidth(l:indent)
		let l:block = commentable#block#New(l:indent)
		let [l:start_line, l:end_line] = l:block.AddExisting(l:at_line)
		let l:lines = l:block.GetFormat(l:block_width)
		call map(l:lines, 'l:indent_chars . v:val')

		"|===============================================|
		"| Replace the block with the newly reformatted  |
		"| block                                         |
		"|===============================================|
		execute (l:start_line
		 \       . ','
		 \       . l:end_line
		 \       . 'call <SID>ReplaceLines(l:lines)')
	endfor
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
	"|===============================================|
	"| Determine the size of the block we're about   |
	"| to construct                                  |
	"|===============================================|
	let l:indent = indent(a:firstline)
	let l:indentchars = substitute(getline(a:firstline),
	 \                             '\m^\(\s*\).*',
	 \                             '\1',
	 \                             '')
	let l:blockwidth = <SID>GetCommentBlockWidth(l:indent)

	"|===============================================|
	"| Get all the paragraphs in range               |
	"|===============================================|
	let l:blockpattern = <SID>GetExistingPattern(a:firstline, a:lastline)
	let l:outfirst = l:blockpattern[0][1]
	let l:outlast = l:blockpattern[-1][2]
	let l:paras = <SID>PatternToParagraphs(l:blockpattern)

	"|===============================================|
	"| Create a block from the paragraphs.           |
	"|===============================================|
	let l:block = commentable#block#New(l:indent)
	for l:para in l:paras
		call l:block.AddParagraph(l:para)
	endfor

	"|===============================================|
	"| Get the lines from the block, and prepare     |
	"|===============================================|
	let l:lines = l:block.GetFormat(l:blockwidth)
	call map(l:lines, 'l:indentchars . v:val')

	"|===============================================|
	"| Dump the lines to file.                       |
	"|===============================================|
	execute l:outfirst . ',' . l:outlast . 'call <SID>ReplaceLines(l:lines)'
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"|                            PRIVATE FUNCTIONS                              |
"|===========================================================================|

"|===========================================================================|
"| s:GetExistingPattern(first, last) abort {{{                               |
"|                                                                           |
"| Scan the pattern of block/lines for source lines in a range.              |
"|                                                                           |
"| PARAMS:                                                                   |
"|   first) Lineno of the first line to scan.                                |
"|   last) Lineno of the last line to scan.                                  |
"|                                                                           |
"| Returns a list of lists where:                                            |
"|   [0] = 'block' or 'lines'                                                |
"|   [1] = starting line number                                              |
"|   [2] = ending line number                                                |
"|===========================================================================|
function! s:GetExistingPattern(first, last) abort
	let l:items = []
	let l:cur_item = ['none', 0, 0]
	let l:cur_line = a:first
	while l:cur_line <= a:last
		if commentable#block#IsComment(l:cur_line)
			call add(l:items, l:cur_item)
			let [l:bs, l:be] = commentable#block#GetBlockRange(l:cur_line)
			let l:cur_item = ['block', l:bs, l:be]
			let l:cur_line = l:be + 1
		else
			if l:cur_item[0] ==# 'lines'
				let l:cur_item[2] = l:cur_line
			else
				call add(l:items, l:cur_item)
				let l:cur_item = ['lines', l:cur_line, l:cur_line]
			endif
			let l:cur_line += 1
		endif
	endwhile

	call add(l:items, l:cur_item)

	return l:items[1:]
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:ParagraphsFromLines(first, last) abort {{{                              |
"|                                                                           |
"| Read a set of lines into paragraph objects.                               |
"|                                                                           |
"| PARAMS:                                                                   |
"|   first) Lineno of the first line to include in the paragraphs.           |
"|   last) Lineno of the last line to include in the paragraphs.             |
"|                                                                           |
"| Returns a list of replacement paragraphs.                                 |
"|===========================================================================|
function! s:ParagraphsFromLines(first, last) abort
	let l:paras = []

	"|===============================================|
	"| Get the lines to put in the block             |
	"|===============================================|
	let l:indent = indent(a:first)
	let l:lines = getline(a:first, a:last)
	call map(l:lines, '<SID>RemoveIndent(l:indent, v:val)')

	"|===============================================|
	"| Create the first paragraph                    |
	"|===============================================|
	let l:cur_par = commentable#paragraph#New(l:lines[0])

	let l:was_last_line_blank = (l:lines[0] =~# '\m^\s*$')
	for l:line in l:lines[1:]
		"|===============================================|
		"| For each of the rest of the lines ...         |
		"|===============================================|
		if l:line =~# '\m^\s*$'
			"|===============================================|
			"| If it's blank, start a new paragraph.         |
			"|===============================================|
			call add(l:paras, l:cur_par)
			let l:cur_par = commentable#paragraph#New(l:line)
			let l:was_last_line_blank = 1
		elseif l:cur_par.IsInParagraph(l:line) && (!l:was_last_line_blank)
			"|===============================================|
			"| If it looks like it fits in this paragraph,   |
			"| add it.                                       |
			"|===============================================|
			call l:cur_par.AddLine(l:line)
		else
			"|===============================================|
			"| Else, start a new paragraph.                  |
			"|===============================================|
			call add(l:paras, l:cur_par)
			let l:cur_par = commentable#paragraph#New(l:line)
			let l:was_last_line_blank = 0
		endif
	endfor

	"|===============================================|
	"| Add the final paragraph                       |
	"|===============================================|
	call add(l:paras, l:cur_par)

	return l:paras
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:PatternToParagraphs(pattern) abort {{{                                  |
"|                                                                           |
"| Turn a block pattern as returned by GetExistingPattern into a list of     |
"| paragraphs with all the text from within the pattern.                     |
"|                                                                           |
"| PARAMS:                                                                   |
"|   pattern) Block pattern to convert.                                      |
"|                                                                           |
"| Returns a list of paragraph objects.                                      |
"|===========================================================================|
function! s:PatternToParagraphs(pattern) abort
	let l:paras = []
	for l:elem in a:pattern
		if l:elem[0] ==# 'block'
			let l:block = commentable#block#New(indent(l:elem[1]))
			call l:block.AddExisting(l:elem[1])
			call extend(l:paras, l:block.paragraphs)
		elseif l:elem[0] ==# 'lines'
			call extend(l:paras,
			 \          <SID>ParagraphsFromLines(l:elem[1], l:elem[2]))
		else
			throw 'Commentable:UNKNOWN ENUM:' . l:elem[0]  " NO COVERAGE
		endif
	endfor

	return l:paras
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:GetCommentBlockWidth(amount_indented) abort {{{                         |
"|                                                                           |
"| Calculate the block width for a block indented the given amount.          |
"|                                                                           |
"| PARAMS:                                                                   |
"|   amount_indented) Characters of indentation in this block.               |
"|                                                                           |
"| Returns the width of the block.                                           |
"|===========================================================================|
function! s:GetCommentBlockWidth(amount_indented) abort
	let l:is_indented = a:amount_indented !=# 0

	"|===============================================|
	"| Get the width.                                |
	"|===============================================|
	if l:is_indented
		try
			let l:width = commentable#util#GetVar('CommentableSubWidth')
			let l:width_var = 'CommentableSubWidth'
		catch /Commentable:NO VALUE:/
		endtry
	endif

	if ! exists('l:width')
		try
			let l:width = commentable#util#GetVar('CommentableBlockWidth')
			let l:width_var = 'CommentableBlockWidth'
		catch /Commentable:NO VALUE:/
		endtry
	endif

	"|===============================================|
	"| Get the column. Fallback to textwidth.        |
	"|===============================================|
	if l:is_indented
		try
			let l:column = commentable#util#GetVar('CommentableSubColumn')
			let l:column_var = 'CommentableSubColumn'
		catch /Commentable:NO VALUE:/
		endtry
	endif

	if ! exists('l:column')
		try
			let l:column = commentable#util#GetVar('CommentableBlockColumn')
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
	 \    (strwidth(l:line) > 0                     &&
	 \     (l:line[0] ==# ' ' || l:line[0] ==# "\t")  )
		if l:line[0] ==# ' '
			let l:sizeleft -= 1
			let l:line = l:line[1:]
		elseif l:line[0] ==# "\t"
			let l:sizeleft -= &tabstop
			let l:line = l:line[1:]
		else
			let l:sizeleft = 0  " NO COVERAGE
		endif
	endwhile

	return l:line
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
