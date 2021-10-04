"       @@@@@@@   @@@@@@@   @@@  @@@  @@@@@@@@
"       @@@@@@@@  @@@@@@@@  @@@  @@@  @@@@@@@@
"       @@!  @@@  @@!  @@@  @@!  @@@  @@!
"       !@   @!@  !@   @!@  !@!  @!@  !@!
"       @!@!@!@   @!@!@!@   @!@  !@!  @!!!:!
"       !!!@!!!!  !!!@!!!!  !@!  !!!  !!!!!:
"       !!:  !!!  !!:  !!!  !!:  !!!  !!:
"       :!:  !:!  :!:  !:!  :!:  !:!  :!:
"       :: ::::   :: ::::  ::::: ::   ::
"       :: : ::   :: : ::    : :  :    :
"
"                  BBUF-plugin
"
" Default prefix is BB
let s:pfx_cmd = get(g:, 'BBUF_pfx_cmd', "BB")
" Add a BBload command
exec "command! " . s:pfx_cmd . "load call BBUF#load()"
if get(g:, s:pfx_cmd . 'LOAD') == 1
	call BBUF#load()
endif
