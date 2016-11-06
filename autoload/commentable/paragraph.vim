"|===========================================================================|
"|                                                                           |
"|         FILE:  autoload/commentable/paragaph.vim                          |
"|                                                                           |
"|  DESCRIPTION:  Paragraph construction class.                              |
"|                                                                           |
"|       AUTHOR:  @galtish                                                   |
"|      CONTACT:  < mj dot git plus commentable at fastmail dot com >        |
"|      LICENCE:  See LICENCE.md                                             |
"|      VERSION:  See plugin/commentable.vim                                 |
"|                                                                           |
"|===========================================================================|

"|===========================================================================|
"|                               CONSTRUCTOR                                 |
"|===========================================================================|

"|===========================================================================|
"| commentable#paragraph#New(intro, indent) abort                        {{{ |
"|                                                                           |
"| Create a new paragraph object.                                            |
"|                                                                           |
"| PARAMS:                                                                   |
"|   intro) Text introducing the paragraph. Any lines after the first will   |
"|          have this length of text as whitespace prepended.                |
"|   indent) Amount of leading whitespace to prepend to every line.          |
"|                                                                           |
"| Returns a paragraph object.                                               |
"|===========================================================================|
function! commentable#paragraph#New(intro, indent) abort
	let l:obj = {
	 \ "indent": a:indent,
	 \ "intro": a:intro,
	 \ "body": "",
	 \ "GetText": function("<SID>GetText"),
	 \ "AddLine": function("<SID>AddLine"),
	 \ }
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"|                              PUBLIC METHODS                               |
"|===========================================================================|

"|===========================================================================|
"| paragraph.GetText(width) abort dict                                   {{{ |
"|                                                                           |
"| PARAMS:                                                                   |
"|   width) The required length of the lines to be output.                   |
"|                                                                           |
"| Returns a list of lines of the requested length comprising the paragraph. |
"|===========================================================================|
function! s:GetText(width) abort dict
	let l:introlength = strlen(l:self.intro)
	let l:reqlength = a:width - l:introlength - l:self.indent

	"|===============================================|
	"| Create a list of lines                        |
	"|===============================================|
	let l:outlist = <SID>BreakIntoLines(l:self.body, l:reqlength)

	"|===============================================|
	"| Prepend intro to first line, equivalent       |
	"| spaces to rest of lines.                      |
	"|===============================================|
	call map(l:outlist, 'repeat(" ",' . l:introlength . ') . v:val')
	let l:outlist[0] = l:self.intro . l:outlist[l:introlength:]

	"|===============================================|
	"| Prepend indent to all lines                   |
	"|===============================================|
	call map(l:outlist, 'repeat(" ",' . l:self.indent . ') . v:val')

	"|===============================================|
	"| Make sure everything is long enough           |
	"|===============================================|
	call map(l:outlist, '<SID>PadRight(v:val, ' . l:reqlength . ', " ")')

	return l:outlist
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| paragraph.AddLine(text) abort dict                                    {{{ |
"|===========================================================================|
function! s:AddLine(text) abort dict
	"|===============================================|
	"| Strip leading and trailing spaces             |
	"|===============================================|
	let l:text = substitute(a:text, '\m^\s*', '', '')
	let l:text = substitute(l:text, '\m\s*$', '', '')

	let l:self.text = l:self.text . ' ' . l:text
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| paragraph.IsInParagraph(line) abort dict                              {{{ |
"|===========================================================================|
function! s:IsInParagraph(text) abort dict
	"|===============================================|
	"| TODO                                          |
	"|===============================================|
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"|                            PRIVATE FUNCTIONS                              |
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
"| s:BreakIntoLines(text, reqlength) abort                               {{{ |
"|===========================================================================|
function! s:BreakIntoLines(text, reqlength) abort
	let l:text = a:text
	let l:textlen = strlen(l:text)
	let l:outlist = []
	while l:textlen > 0
		if l:textlen <= a:reqlen
			"|===============================================|
			"| Add all the text                              |
			"|===============================================|
			call add(l:outlist, l:text)
			let l:text = ''
		else
			"|===============================================|
			"| Find the last valid space to break at         |
			"|===============================================|
			let l:lastspaceidx = -1
			for l:idx in range(a:reqlen - 1, 0, -1)
				if l:text[l:idx] ==# ' '
					let l:lastspaceidx = l:idx
					break
				endif
			endfor

			if l:lastspaceidx == -1
				"|===============================================|
				"| Look forward for the space                    |
				"|===============================================|
				for l:idx in range(a:reqlen, l:textlen - 1)
					if l:text[l:idx] ==# ' '
						let l:lastspaceidx = l:idx
						break
					endif
				endfor
			endif

			if l:lastspaceidx == -1
				"|===============================================|
				"| Still no space, just add everything           |
				"|===============================================|
				call add(l:outlist, l:text)
				let l:text = ''
			else
				"|===============================================|
				"| Have a space to break at                      |
				"|===============================================|
				if l:lastspaceidx == 0
					"|===============================================|
					"| No chars before space                         |
					"|===============================================|
					let l:text = l:text[1:]
				elseif l:lastspaceidx == l:textlen - 1
					"|===============================================|
					"| No chars after space                          |
					"|===============================================|
					call add(l:outlist, substitute(l:text, '\m\s*$', '', ''))
					let l:text = ''
				else
					"|===============================================|
					"| Found an appropriate space                    |
					"|===============================================|
					call add(l:outlist, l:text[:(l:lastspaceidx - 1)])
					let l:text = l:text[(l:lastspaceidx + 1):]
				endif
			endif
		endif

		"|===============================================|
		"| Set textlen and loop                          |
		"|===============================================|
		let l:textlen = strlen(l:text)
	endwhile
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
