"|===========================================================================|
"|                                                                           |
"|         FILE:  autoload/commentable/block.vim                             |
"|                                                                           |
"|  DESCRIPTION:  Block construction class.                                  |
"|                                                                           |
"|===========================================================================|

"|===========================================================================|
"|                            SCRIPT CONSTANTS                               |
"|===========================================================================|
let s:t_number = v:version >= 800 ? v:t_number : type(0)
let s:t_list   = v:version >= 800 ? v:t_list   : type([])
let s:t_string = v:version >= 800 ? v:t_string : type('')

"|===========================================================================|
"|                                  ENUMS                                    |
"|===========================================================================|

let g:commentable#block#lmat_none = 0 " Not part of a comment
let g:commentable#block#lmat_int  = 1 " Internal comment line
let g:commentable#block#lmat_wall = 2 " Wall of a comment

"|===========================================================================|
"|                                  CLASS                                    |
"|===========================================================================|

"|===========================================================================|
"| commentable#block#New(indentamount) {{{                                   |
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
	let l:self = {
	 \ 'style': commentable#style#New(a:indentamount),
	 \ 'paragraphs': [],
	 \ 'initialmatch': 1,
	 \ }

	"|===============================================|
	"|                 PUBLIC METHODS                |
	"|===============================================|

	"|===============================================|
	"| self.AddParagraph(para) {{{                   |
	"|                                               |
	"| Add a new paragraph of text to this block.    |
	"|                                               |
	"| PARAMS:                                       |
	"|   para) The paragraph to add. Adds the exact  |
	"|         object, not a copy.                   |
	"|                                               |
	"| Returns nothing.                              |
	"|===============================================|
	function! l:self.AddParagraph(para)
		call add(l:self.paragraphs, a:para)
	endfunction!
	"|===============================================|
	"| }}}                                           |
	"|===============================================|

	"|===============================================|
	"| self.AddExisting(linenum) {{{                 |
	"|                                               |
	"| Add paragraphs from an existing block.        |
	"|                                               |
	"| PARAMS:                                       |
	"|   linenum) A line in the exisiting paragraph. |
	"|            Will read forwards and backwards   |
	"|            from this line to try to find the  |
	"|            full paragraph.                    |
	"|                                               |
	"| Returns [firstline, lastline], showing which  |
	"| lines were used. Throws if the given line is  |
	"| not in the paragraph.                         |
	"|===============================================|
	function! l:self.AddExisting(linenum)
		let [l:firstline, l:lastline] = l:self._GetRange(a:linenum)

		let [l:initmatch, l:medial, l:final, l:spacer] = [
			\ l:self.style.initMatch,
			\ l:self.style.medial,
			\ l:self.style.final,
			\ l:self.style.spacer,
			\ ]

		let l:lines = getline(l:firstline, l:lastline)
		call map(l:lines, 'commentable#util#StripSpaces(v:val)')
		call map(l:lines, 'substitute(v:val, ''\V\^' . l:initmatch . ''', "", "")')
		call map(l:lines, 'substitute(v:val, ''\V' . l:final . '\$'', "", "")')

		if match(l:lines[0], '\V\^' . l:medial . '\*\$') == 0
			call remove(l:lines, 0)
		endif

		if len(l:lines) > 0                                    &&
		 \ match(l:lines[-1], '\V\^' . l:medial . '\*\$') == 0
			call remove(l:lines, -1)
		endif

		call map(l:lines,
		 \       'substitute(v:val, ''\V\^' . l:medial . ''', "", "")')

		if l:spacer !=# ''
			call map(l:lines,
			 \       'substitute(v:val, ''\V\^' . l:spacer . ''', "", "")')
			call map(l:lines,
			 \       'substitute(v:val, ''\V' . l:spacer . '\$'', "", "")')
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
	"|===============================================|
	"| }}}                                           |
	"|===============================================|

	"|===============================================|
	"| self.LineMatches(linenum) {{{                 |
	"|                                               |
	"| Determine if a given existing line is valid   |
	"| for this block.                               |
	"|                                               |
	"| PARAMS:                                       |
	"|   linenum) The line to verify.                |
	"|                                               |
	"| Returns a commentable#block#lmat value.       |
	"|===============================================|
	function! l:self.LineMatches(linenum)
		let l:text = getline(a:linenum)
		let l:text = substitute(l:text, '\m^\s*', '', '')
		let l:text = substitute(l:text, '\m\s*$', '', '')

		let l:iscomment = g:commentable#block#lmat_none

		let [l:initial, l:initmatch, l:medial, l:final] = [
			\ l:self.style.initial,
			\ l:self.style.initMatch,
			\ l:self.style.medial,
			\ l:self.style.final,
			\ ]

		if type(l:self.initialmatch) ==# s:t_number
			let l:str = matchstr(l:text, '\v^' . l:initmatch)
			if l:str !=# ''
				let l:self.initialmatch = l:str
				let l:iscomment = g:commentable#block#lmat_int
			elseif ((l:final !=# '')                           &&
			 \      (strwidth(l:text) >= strwidth(l:final))    &&
			 \      (match(l:text, '\V' . l:final)
			 \       == strwidth(l:text) - strwidth(l:final)))   ||
			 \     ((l:medial !=# '')                          &&
			 \      (a:linenum > 1)                            &&
			 \      (strwidth(l:text) >= strwidth(l:medial))   &&
			 \      (match(l:text, '\V' . l:medial) == 0)      &&
			 \      (l:self.LineMatches(a:linenum - 1)))
				let l:iscomment = g:commentable#block#lmat_int
			endif
		elseif (match(l:text, '\V' . l:self.initialmatch) == 0)   ||
		 \     ((l:final !=# '')                                &&
		 \      (strwidth(l:text) >= strwidth(l:final))         &&
		 \      (match(l:text, '\V' . l:final)
		 \       == strwidth(l:text) - strwidth(l:final)))        ||
		 \     ((l:medial !=# '')                               &&
		 \      (a:linenum > 1)                                 &&
		 \      (strwidth(l:text) >= strwidth(l:medial))        &&
		 \      (match(l:text, '\V' . l:medial) == 0)           &&
		 \      (l:self.LineMatches(a:linenum - 1)))
			let l:iscomment = g:commentable#block#lmat_int
		endif

		"|===============================================|
		"| We know this is a line, check if it's a wall. |
		"|===============================================|
		if l:iscomment == g:commentable#block#lmat_int   &&
		 \ match(l:text, '\V\^' . l:initial
		 \                      . l:medial  . '\*'
		 \                      . l:final   . '\$') == 0
			if type(l:self.initialmatch) ==# s:t_number
				if match(l:text, '\V\^' . l:initmatch
				 \                      . l:medial  . '\*'
				 \                      . l:final   . '\$') == 0
					let l:iscomment = g:commentable#block#lmat_wall
				endif
			elseif match(l:text, '\V\^' . l:self.initialmatch
			 \                          . l:medial  . '\*'
			 \                          . l:final   . '\$') == 0
				let l:iscomment = g:commentable#block#lmat_wall
			endif
		endif

		return l:iscomment
	endfunction
	"|===============================================|
	"| }}}                                           |
	"|===============================================|

	"|===============================================|
	"| self.GetFormat(width) {{{                     |
	"|                                               |
	"| PARAMS:                                       |
	"|   width) The required length of the lines to  |
	"|          be output.                           |
	"|                                               |
	"| Returns a list of lines of the requested      |
	"| length comprising the block.                  |
	"|===============================================|
	function! l:self.GetFormat(width)
		let [l:initial, l:medial, l:final, l:spacer] = [
			\ l:self.style.initial,
			\ l:self.style.medial,
			\ l:self.style.final,
			\ l:self.style.spacer,
			\ ]

		if type(l:self.initialmatch) != s:t_number
			"|===============================================|
			"| If we've set the initial match then use that  |
			"| to recreate the comment.                      |
			"|===============================================|
			let l:initial = l:self.initialmatch
		endif

		let l:textlen = a:width
		 \            - strwidth(l:initial)
		 \            - strwidth(l:final)
		 \            - (2 * strwidth(l:spacer))

		let l:lines = []
		for l:para in l:self.paragraphs
			call extend(l:lines, l:para.GetFormat(l:textlen))
		endfor

		if l:spacer !=# ''
			call map(l:lines, 'l:spacer . v:val . l:spacer')
		endif

		call map(l:lines, 'l:initial . v:val . l:final')

		if l:medial !=# ''
			let l:wall = l:initial
			 \         . strpart(repeat(l:medial, a:width),
			 \                   0,
			 \                   a:width - strwidth(l:initial)
			 \                           - strwidth(l:final))
			 \         . l:final
			call insert(l:lines, l:wall)
			call add(l:lines, l:wall)
		endif

		return l:lines
	endfunction
	"|===============================================|
	"| }}}                                           |
	"|===============================================|

	"|===============================================|
	"|                PRIVATE METHODS                |
	"|===============================================|

	"|===============================================|
	"| self._GetRange(linenum) {{{                   |
	"|                                               |
	"| Get block range around a given line.          |
	"|                                               |
	"| PARAMS:                                       |
	"|   linenum) The line around which to get the   |
	"|            range.                             |
	"|                                               |
	"| Returns the 2list [l:first, l:last] of the    |
	"| range. If the specified line is not part of a |
	"| block, throws.                                |
	"|===============================================|
	function! l:self._GetRange(linenum)
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
	"|===============================================|
	"| }}}                                           |
	"|===============================================|

	return l:self
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"|                            PUBLIC FUNCTIONS                               |
"|===========================================================================|

"|===========================================================================|
"| commentable#block#GetBlockRange(lineno) abort {{{                         |
"|                                                                           |
"| Get the range of a block at a given line.                                 |
"|                                                                           |
"| PARAMS:                                                                   |
"|   lineno) Line to search around.                                          |
"|                                                                           |
"| Returns [firstline, lastline] of the block. Will throw if the given line  |
"| is not a part of the block.                                               |
"|===========================================================================|
function! commentable#block#GetBlockRange(lineno) abort
	return commentable#block#New(indent(a:lineno))._GetRange(a:lineno)
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| commentable#block#IsComment(lineno) abort {{{                             |
"|                                                                           |
"| Determine if a given line is part of a block.                             |
"|                                                                           |
"| PARAMS:                                                                   |
"|   lineno) Line to check.                                                  |
"|                                                                           |
"| Returns true/false.                                                       |
"|===========================================================================|
function! commentable#block#IsComment(lineno) abort
	return commentable#block#New(indent(a:lineno)).LineMatches(a:lineno)
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
