"|===========================================================================|
"|                                                                           |
"|         FILE:  autoload/commentable/paragaph.vim                          |
"|                                                                           |
"|  DESCRIPTION:  Paragraph construction class.                              |
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
"| commentable#paragraph#New(line) abort {{{                                 |
"|                                                                           |
"| Create a new paragraph object.                                            |
"|                                                                           |
"| PARAMS:                                                                   |
"|   line) The first line of the paragraph, which determines the indent and  |
"|         intro string.                                                     |
"|                                                                           |
"| Returns a paragraph object.                                               |
"|===========================================================================|
function! commentable#paragraph#New(line) abort
	let [l:indent, l:intro] = <SID>GetLineIntro(a:line)
	let l:restofline = a:line[(l:indent + strlen(l:intro)):]
	let l:self = {
	 \ 'indent': l:indent,
	 \ 'intro': l:intro,
	 \ 'body': '',
	 \ 'GetFormat': function('<SID>GetFormat'),
	 \ 'AddLine': function('<SID>AddLine'),
	 \ 'IsInParagraph': function('<SID>IsInParagraph'),
	 \ }

	if l:restofline !=# ''
		call l:self.AddLine(l:restofline)
	endif

	return l:self
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"|                              PUBLIC METHODS                               |
"|===========================================================================|

"|===========================================================================|
"| paragraph.GetFormat(width) abort dict {{{                                 |
"|                                                                           |
"| PARAMS:                                                                   |
"|   width) The required length of the lines to be output.                   |
"|                                                                           |
"| Returns a list of lines of the requested length comprising the paragraph. |
"|===========================================================================|
function! s:GetFormat(width) abort dict
	let l:introlength = strlen(l:self.intro)
	let l:reqlength = a:width - l:introlength - l:self.indent

	"|===============================================|
	"| Create a list of lines                        |
	"|===============================================|
	let l:outlist = <SID>BreakIntoLines(l:self.body, l:reqlength)

	"|===============================================|
	"| Make sure everything is long enough           |
	"|===============================================|
	call map(l:outlist, '<SID>PadRight(v:val, ' . l:reqlength . ', " ")')

	"|===============================================|
	"| Prepend intro to first line, equivalent       |
	"| spaces to rest of lines.                      |
	"|===============================================|
	call map(l:outlist, 'repeat(" ",' . l:introlength . ') . v:val')
	let l:outlist[0] = l:self.intro . l:outlist[0][(l:introlength):]

	"|===============================================|
	"| Prepend indent to all lines                   |
	"|===============================================|
	call map(l:outlist, 'repeat(" ",' . l:self.indent . ') . v:val')

	return l:outlist
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| paragraph.AddLine(line) abort dict {{{                                    |
"|                                                                           |
"| Add the given line to this paragraph.                                     |
"|                                                                           |
"| PARAMS:                                                                   |
"|   line) The line to add.                                                  |
"|                                                                           |
"| Returns nothing.                                                          |
"|===========================================================================|
function! s:AddLine(line) abort dict
	"|===============================================|
	"| Strip leading and trailing spaces             |
	"|===============================================|
	let l:line = substitute(a:line, '\m^\s*', '', '')
	let l:line = substitute(l:line, '\m\s*$', '', '')

	if l:self.body ==# ''
		let l:self.body = l:line
	else
		let l:self.body .= ' ' . l:line
	endif
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| paragraph.IsInParagraph(line) abort dict {{{                              |
"|                                                                           |
"| Determine if the given line belong to this paragraph by checking leading  |
"| whitespace.                                                               |
"|                                                                           |
"| PARAMS:                                                                   |
"|   line) The line to check.                                                |
"|                                                                           |
"| Returns 1 if the line belongs, else 0.                                    |
"|===========================================================================|
function! s:IsInParagraph(line) abort dict
	let [l:nindent, l:nintro] = <SID>GetLineIntro(a:line)

	if l:nintro !=# ''
		"|===============================================|
		"| This line matches an intro, so must be a new  |
		"| paragraph.                                    |
		"|===============================================|
		return 0
	endif

	let l:expectedindent = l:self.indent + strlen(l:self.intro)
	if l:expectedindent == l:nindent
		return 1
	else
		return 0
	endif
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"|                            PRIVATE FUNCTIONS                              |
"|===========================================================================|

"|===========================================================================|
"| s:PadRight(text, reqlength, padding) abort {{{                            |
"|                                                                           |
"| Pad the given text until it reaches the required length.                  |
"|                                                                           |
"| PARAMS:                                                                   |
"|   text) The text to pad.                                                  |
"|   reqlength) The length to pad until.                                     |
"|   padding) The character to use for padding.                              |
"|                                                                           |
"| Returns the padded text.                                                  |
"|===========================================================================|
function! s:PadRight(text, reqlength, padding) abort
	let l:textlength = strlen(a:text)
	let l:fillerlength = strlen(a:padding)

	if l:fillerlength == 0 || l:textlength >= a:reqlength
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
"| s:BreakIntoLines(text, reqlen) abort {{{                                  |
"|                                                                           |
"| Breaks a text string or list of strings into a list of lines of a given   |
"| length.                                                                   |
"|                                                                           |
"| PARAMS:                                                                   |
"|   text) Text to normalise. Either a string or a list of strings.          |
"|   reqlen) Desired length of output lines. Lines will be this length or    |
"|           shorted, unless a single word is longer than this length, in    |
"|           which case the lines will be of that length.                    |
"|                                                                           |
"| Returns the lines of the required length.                                 |
"|===========================================================================|
function! s:BreakIntoLines(text, reqlen) abort
	let l:text = a:text
	if type(l:text) == s:t_list
		let l:text = join(l:text)
	endif
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
			for l:idx in range(a:reqlen, 0, -1)
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

	if len(l:outlist) == 0
		call add(l:outlist, '')
	endif

	return l:outlist
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:GetLineIntro(line) abort {{{                                            |
"|                                                                           |
"| PARAMS:                                                                   |
"|   line) The line to extract elements of.                                  |
"|                                                                           |
"| Returns a 2list [indentsize, introstr] from the line.                     |
"|===========================================================================|
function! s:GetLineIntro(line) abort
	let l:introvarname = 'CommentableParagraphIntro'
	let l:prependspaces = 1

	try
		let l:intromatch = commentable#GetVar(l:introvarname)
	catch /^Commentable:NO VALUE:/
	endtry

	if !has_key(l:, 'intromatch')
		let l:intromatch = <SID>IntroFromListPat()
		let l:introvarname = 'formatlistpat'
		let l:prependspaces = 0
	endif

	if type(l:intromatch) != s:t_list
		throw 'Commentable:INVALID SETTING:' . l:introvarname
	endif

	for l:elem in l:intromatch
		if type(l:elem) != s:t_string ||
		 \ l:elem ==# ''
			throw 'Commentable:INVALID SETTING:' . l:introvarname
		endif
	endfor

	"|===============================================|
	"| Prefix each matcher with lots of spaces       |
	"|===============================================|
	if l:prependspaces
		let l:intromatch =
		 \ map(copy(l:intromatch), '''\m\C^\s*'' . v:val')
	endif

	let [l:intro, l:introstart, l:introend] = ['', -1, -1]

	for l:trial in l:intromatch
		let l:introstart = match(a:line, l:trial)
		if l:introstart != -1
			let l:introend = matchend(a:line, l:trial) - 1
			let l:intro = a:line[(l:introstart):(l:introend)]
			break
		endif
	endfor

	let l:retsize = 0
	let l:retstr = ''

	if l:introstart != -1
		"|===============================================|
		"| Got an intro                                  |
		"|===============================================|
		let l:retsize = l:introstart
		let l:retstr = l:intro
	else
		"|===============================================|
		"| No intro, just indent                         |
		"|===============================================|
		let l:retsize = strlen(substitute(a:line, '\m^\(\s*\).*', '\1', ''))
	endif

	return [l:retsize, l:retstr]
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:IntroFromListPat() abort {{{                                            |
"|                                                                           |
"| Generate an introlist from the 'formatlistpat'.                           |
"|                                                                           |
"| PARAMS: None.                                                             |
"|                                                                           |
"| Returns the singlet introlist.                                            |
"|===========================================================================|
function! s:IntroFromListPat() abort
	return [&formatlistpat]
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
