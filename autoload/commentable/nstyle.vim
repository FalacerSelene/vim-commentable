"|===========================================================================|
"|                                                                           |
"|         FILE:  autoload/commentable/nstyle.vim                            |
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
"|                                  CLASS                                    |
"|===========================================================================|

function! commentable#nstyle#New(indented) abort
	let l:indented = a:indented > 0 ? 1 : 0
	let l:self = {
	 \   'indented': l:indented,
	 \   'source': 'null',
	 \   'initMatch': '',
	 \   'initial': '',
	 \   'medial': '',
	 \   'final': '',
	 \   'spacer': '',
	 \ }

	"|===============================================|
	"| self.refresh() {{{                            |
	"|                                               |
	"| Update the style from the new environment.    |
	"|                                               |
	"| PARAMS: None.                                 |
	"|                                               |
	"| Returns itself, or throws if unable.          |
	"|===============================================|
	function l:self.refresh()
		if l:self.indented && commentable#util#HasVar('CommentableSubStyle')
			return l:self.refreshVarList(
				\ commentable#util#GetVar('CommentableSubStyle'),
				\ 'CommentableSubStyle')
		endif

		if commentable#util#HasVar('CommentableBlockStyle')
			return l:self.refreshVarList(
				\ commentable#util#GetVar('CommentableBlockStyle'),
				\ 'CommentableBlockStyle')
		endif

		return l:self.refreshCommentString()
	endfunction
	"|===============================================|
	"| }}}                                           |
	"|===============================================|

	"|===============================================|
	"| self.refreshVarList(lst, name) {{{            |
	"|                                               |
	"| Update the style from the provided var-list.  |
	"|                                               |
	"| After normalisation, a var list must:         |
	"| - Be a 4 list.                                |
	"| - Where the first element is a 2 list of      |
	"|   strings.                                    |
	"| - Where the remaining 3 elements are strings. |
	"|                                               |
	"| PARAMS:                                       |
	"|   list) The list, as defined by the user.     |
	"|   name) The name of the source var.           |
	"|                                               |
	"| Returns itself, or throws if unable.          |
	"|===============================================|
	function l:self.refreshVarList(list, name)
		"|===============================================|
		"| It must be a list of length 3 or 4.           |
		"|===============================================|
		if type(a:list) != s:t_list || !(len(a:list) == 3 || len(a:list) == 4)
			throw 'Commentable:INVALID SETTING:' . a:name
		endif

		"|===============================================|
		"| First elem must be a string or a 2list of     |
		"| strings.                                      |
		"|===============================================|
		if type(a:list[0]) == s:t_string
			let l:initMatch = a:list[0]
			let l:init = a:list[0]
		elseif type(a:list[0]) == s:t_list && len(a:list[0]) == 2
			if !(type(a:list[0][0]) == s:t_string && type(a:list[0][1]) == s:t_string)
				throw 'Commentable:INVALID SETTING:' . a:name
			endif

			let l:initMatch = a:list[0][1]
			let l:init = a:list[0][0]
		else
			throw 'Commentable:INVALID SETTING:' . a:name
		endif

		"|===============================================|
		"| Init and initmatch must not have leading      |
		"| whitespace, nor be empty.                     |
		"|===============================================|
		if l:init ==# '' || l:initMatch ==# ''
		 \ || l:init =~# '^\s\+' || l:initMatch =~# '^\s\+'
			throw 'Commentable:INVALID SETTING:' . a:name
		endif

		for l:item in a:list[1:]
			if type(l:item) != s:t_string
				throw 'Commentable:INVALID SETTING:' . a:name
			endif
		endfor

		if len(a:list) == 3
			let l:spacer = ' '
		else
			let l:spacer = a:list[3]
		endif

		"|===============================================|
		"| Final must not have trailing whitespace       |
		"|===============================================|
		let l:final = a:list[2]
		if l:final =~# '\s\+$'
			throw 'Commentable:INVALID SETTING:' . a:name
		endif

		let l:self.source = a:name
		let l:self.initMatch = '\V' . l:initMatch
		let l:self.initial = l:init
		let l:self.medial = a:list[1]
		let l:self.final = l:final
		let l:self.spacer = l:spacer

		return l:self
	endfunction
	"|===============================================|
	"| }}}                                           |
	"|===============================================|

	"|===============================================|
	"| self.refreshCommentString() {{{               |
	"|                                               |
	"| Update the style from the new environment.    |
	"|                                               |
	"| PARAMS: None.                                 |
	"|                                               |
	"| Returns itself, or throws if unable.          |
	"|===============================================|
	function l:self.refreshCommentString()
		if &commentstring !~# '%s'
			throw 'Commentable:INVALID SETTING:&commentstring'
		endif

		let [l:fullmatch, l:start, l:end; l:_] =
		 \  matchlist(&commentstring, '\v^(.*)\%s(.*)$')

		let l:self.source = '&commentstring'
		let l:self.initMatch = '\V' . l:start
		let l:self.initial = l:start
		let l:self.medial = ''
		let l:self.final = l:end
		let l:self.spacer = ''

		return l:self
	endfunction
	"|===============================================|
	"| }}}                                           |
	"|===============================================|

	return l:self.refresh()
endfunction
