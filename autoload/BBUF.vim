"                   @@@@@@@   @@@@@@@   @@@  @@@  @@@@@@@@
"                   @@@@@@@@  @@@@@@@@  @@@  @@@  @@@@@@@@
"                   @@!  @@@  @@!  @@@  @@!  @@@  @@!
"                   !@   @!@  !@   @!@  !@!  @!@  !@!
"                   @!@!@!@   @!@!@!@   @!@  !@!  @!!!:!
"                   !!!@!!!!  !!!@!!!!  !@!  !!!  !!!!!:
"                   !!:  !!!  !!:  !!!  !!:  !!!  !!:
"                   :!:  !:!  :!:  !:!  :!:  !:!  :!:
"                   :: ::::   :: ::::  ::::: ::   ::
"                   :: : ::   :: : ::    : :  :    :

" Debug tool
" for c in g:Deblog2.boot() | exe c | endfor
" See: https://github.com/Termplexed/deblog

let s:bufs_named = { 'default': [] }
let s:named_cur = 'default'
let s:bufs = s:bufs_named[s:named_cur]

" If 1 echo out list after modifying list
let s:verbosity    = get(g:, 'BBUF_verbosity', 0)
" If 1 go to alternate buffer when list is empty and calling BBNEXT / BBBACK
let s:go_alternate = get(g:, 'BBUF_go_alternate_on_empty', 0)
" Prefix for commands. Default BB
let s:pfx_cmd      = get(g:, 'BBUF_pfx_cmd', "BB")

" Is Number helper
fun! s:is_number(s)
	return a:s =~# '^\d\+$'
endfun

" Echo help
fun! s:bufs_help()
	echo "Bufs Cycle - Keep a list of buffers to cycle"
	echo " "
	echo "BBback          Go to previous"
	echo "BBforward       Go to next"
	echo "BBls            Show list"
	echo "BBclr           Clear list"
	echo "BBdel X X ...   Remove buffer X"
	echo "BBadd X X ...   Push buffer X on to stack."
	echo "BBset X X ...   Set list to buffers X, X, ..."
	echo " "
	echo "Buffers (X) can be buffer-numbers or file-globs"
	echo " "
	echo "(Ctrl-Shift-Left)  Go to previous in list          BBback"
	echo "(Ctrl-Shift-Right) Go to next in list              BBforward"
	echo "(Ctrl-Shift-Up)    Push current buffer to list     BBadd <current>"
	echo "(Ctrl-Shift-Down)  Remove current buffer from list BBdel <current>"
	echo " "
	echo "See help file for full list"
endfun

" echo current list
fun! s:bufs_list(bufs)
	let ls = []
	for b in a:bufs
		let ls += [printf("%3d) %s", b, bufname(b))]
	endfor
	echo len(ls) ? join(ls, "\n") : "Empty"
endfun

" Clear list - as function in case one decide to add some more to it :P
fun! s:bufs_clear()
	let s:bufs_named[s:named_cur] = []
	let s:bufs = s:bufs_named[s:named_cur]
endfun
fun! s:bufs_clear_all()
	let s:bufs_named = { 'default': [] }
	let s:named_cur = 'default'
	let s:bufs = s:bufs_named[s:named_cur]
endfun

" Adder-helper
fun! s:buf_add(buf_list, buf)
	if s:is_number(a:buf)
		let add = [a:buf + 0]
	else
		" filter() filenames against argument converted from
		" glob to regular expression.
		" map() Convert file-names to buffer numbers.
		let add = map(
			\ filter(a:buf_list, 'v:val =~# glob2regpat(a:buf)'),
			\ 'bufnr(v:val)')
	endif
	let s:bufs += filter(add, 'index(s:bufs, v:val) == -1')
endfun
" Adder main
fun! s:bufs_add(mode, ...)
	" Add current + alternate buffer if mode is set and s:bufs is empty.
	" This way doing i.e. :BBPUSH 12 results in [current, alternate, 12]
	" Believe this is more user-friendly then [12]
	" For [12] one can use :BBSET 12
	if a:mode == 'push'
		if !len(s:bufs)
			let s:bufs = [ bufnr('%')]
			if bufnr('#') != -1
				let s:bufs += [ bufnr('#')]
			endif
		endif
	elseif a:mode == 'set'
		call s:bufs_clear()
	endif
	if a:mode == 'this'
		if index(s:bufs, bufnr('%')) == -1
			let s:bufs += [bufnr('%')]
		endif
	elseif a:0 == 1 && s:is_number(a:1)
		" Limit resource usage if we only have one argument and that
		" is a buffer-number.
		let s:bufs += [ a:1 + 0 ]
	else
		" List with all filenames for open buffers
		let buf_list = map(getbufinfo({'buflisted': 1}), 'v:val.name')
		for b in a:000
			call s:buf_add(buf_list, b)
		endfor
	endif
	let s:bufs_named[s:named_cur] = s:bufs
	if s:verbosity > 0
		call s:bufs_list(s:bufs)
	endif
endfun

" Removal-helper
fun! s:buf_rm(buf_list, buf)
	if s:is_number(a:buf)
		let s:bufs = filter(s:bufs, 'v:val != a:buf + 0')
	else
		" filter() filenames against argument converted from
		" glob to regular expression.
		" map() Convert file-names to buffer numbers.
		let s:bufs = filter(
			\ filter(a:buf_list, 'v:val =~# glob2regpat(a:buf)'),
			\ 'bufnr(v:val)')
	endif
endfun
" Removal main
fun! s:bufs_del(...)
	if a:1 == 'this'
		let s:bufs = filter(s:bufs, 'v:val != bufnr("%")')
	else
		let buf_list = map(getbufinfo({'buflisted': 1}), 'v:val.name')
		for b in a:000[1:]
			call s:buf_rm(buf_list, b)
		endfor
	endif
	let s:bufs_named[s:named_cur] = s:bufs
	if s:verbosity > 0
		call s:bufs_list(s:bufs)
	endif
endfun

fun! s:bufs_named_add(name)
	if !s:bufs_named->has_key(a:name)
		let s:bufs_named[a:name] = []
	endif
	let s:bufs = s:bufs_named[a:name]
	let s:named_cur = a:name
endfun
fun! s:bufs_named_rename(...)
	if a:0 == 1
		let from = s:named_cur
		let to = a:1
	else
		let from = a:1
		let to = a:2
	endif
	if !s:bufs_named->has_key(to)
		let s:bufs_named[to] = copy(s:bufs_named[from])
		unlet s:bufs_named[from]
		if a:0 == 1
			let s:named_cur = to
		endif
	else
		echo "Name exists"
	endif
endfun
fun! s:bufs_named_delete(name)
	if s:bufs_named->has_key(a:name)
		unlet s:bufs_named[a:name]
	endif
	if a:name == s:named_cur
		if has_key(s:bufs_named, 'default')
			let s:named_cur = 'default'
		elseif len(s:bufs_named)
			let s:named_cur = keys(s:bufs_named)[0]
		else
			call s:bufs_clear()
			let s:named_cur = 'default'
		endif
		let s:bufs = s:bufs_named[s:named_cur]
	endif
endfun

" Navigation in list
fun! s:bufs_next(dir)
	let n = len(s:bufs)
	if !n
		if s:go_alternate
			b#
		endif
		return
	endif
	let cur = bufnr('%') + 0
	let i = index(s:bufs, cur)
	let i += a:dir == 'N' ? 1 : -1
	if i < 0
		exec 'b' . s:bufs[n - 1]
	elseif i == n
		exec 'b' . s:bufs[0]
	else
		exec 'b' . s:bufs[i]
	endif
endfun
fun! s:bufs_go(b)
	echo "Not implemented Go " . a:b
endfun
" echo named lists
fun! s:bufs_named_list(...)
	for k in keys(s:bufs_named)
		echohl Number
		echo k . (k == s:named_cur ? ' *' : '')
		echohl None
		call s:bufs_list(s:bufs_named[k])
	endfor
endfun

fun! s:Comp_bufs(A, L, P)
	let x = []
	if !len(s:bufs)
		return x
	endif
	for k in s:bufs
		let x += [ k . "", bufname(k) ]
	endfor
	let z = len(a:A) - 1
	if z > -1
		let x = filter(x, 'v:val[0:z] == a:A')
	endif
	return x
endfun

" NB! No check if command already exists. (at least for now)
" Change name, e.g. "back" to what ever you want
"
" Default prefix for commands is BB, change by setting g:BB_pfx_cmd to what
" you want in .vimrc
let s:Commands =
	\ {
	\ "back":        "command! -nargs=0 CMD call s:bufs_next('P')",
	\ "clr":         "command! -nargs=0 CMD call s:bufs_clear()",
	\ "clrall":      "command! -nargs=0 CMD call s:bufs_clear_all()",
	\ "help":        "command! -nargs=0 CMD call s:bufs_help()",
	\ "ls":          "command! -nargs=0 CMD call s:bufs_list(s:bufs)",
	\ "lsnamed":     "command! -nargs=* CMD call s:bufs_named_list(<f-args>)",
	\ "forward":     "command! -nargs=0 CMD call s:bufs_next('N')",
	\ "namedadd":    "command! -nargs=1 CMD call s:bufs_named_add(<f-args>)",
	\ "namedls":     "command! -nargs=* CMD call s:bufs_named_list(<f-args>)",
	\ "rename":      "command! -nargs=+ CMD call s:bufs_named_rename(<f-args>)",
	\ "namedrename": "command! -nargs=+ CMD call s:bufs_named_rename(<f-args>)",
	\ "nameddelete": "command! -nargs=1 CMD call s:bufs_named_delete(<f-args>)",
	\ "add":  "command! -nargs=+ CMD call s:bufs_add('push', <f-args>)",
	\ "del":  "command! -nargs=+ CMD call s:bufs_del('cmd', <f-args>)",
	\ "set":  "command! -nargs=+ CMD call s:bufs_add('set', <f-args>)",
	\ "go":
	\ "command! -nargs=1 -complete=customlist,s:Comp_bufs CMD call s:bufs_go(<f-args>)",
	\ }
" Debug remove
call map(s:Commands, 'execute(substitute(v:val, "CMD", s:pfx_cmd . v:key, ""))')
" Minor Cleanup
unlet s:Commands
unlet s:pfx_cmd

" Maps - change to your pref. (Column 3)
" Unmap by adding a " at start of line (comment out)
noremap <silent> <C-S-Left>  :call <SID>bufs_next('P')<CR>
noremap <silent> <C-S-Right> :call <SID>bufs_next('N')<CR>
noremap <silent> <C-S-Up>    :call <SID>bufs_add('this')<CR>
noremap <silent> <C-S-Down>  :call <SID>bufs_del('this')<CR>

fun! BBUF#load()
	let pfx_cmd = get(g:, 'BBUF_pfx_cmd', "BB")
	exec "delcommand " . pfx_cmd . "load"
endf
