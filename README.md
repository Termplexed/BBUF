<h1 align="center">~ BBUF ~</h1>
<div align="center">
<pre>
     @@@@@@@   @@@@@@@   @@@  @@@  @@@@@@@@
     @@@@@@@@  @@@@@@@@  @@@  @@@  @@@@@@@@
@@!  @@@  @@!  @@@  @@!  @@@  @@!
!@   @!@  !@   @!@  !@!  @!@  !@!
    @!@!@!@   @!@!@!@   @!@  !@!  @!!!:!
    !!!@!!!!  !!!@!!!!  !@!  !!!  !!!!!:
!!:  !!!  !!:  !!!  !!:  !!!  !!:
:!:  !:!  :!:  !:!  :!:  !:!  :!:
:: ::::   :: ::::  ::::: ::   ::
:: : ::   :: : ::    : :  :    :

    _^0_o^__
</pre>
</div>

---

A Vim plugin to render help when working with collection / sets of buffers.

Say you have 40 buffers open and want to work with more then two and not
want to keep entering buffer numbers ... 

Use BBUF and create a collection of say buffers 3, 6, 11 and 24 and user
key-shortcuts to cycle this list.

You can create multiple buffer collections and give them different names. For example:

`foo`: Has buffers 3, 6, 12<br>
`bar`: Has buffers 3, 9, 13<br>
`baz`: Has buffers 1, 16, 12, 3, 5<br>
etc.

Simplest - Typically:

```
:BBload  " to load the BBUF plugin
:BBhelp  " quick help
:BB<TAB> " list functions
```

Then do for example:

```
:BBset 1 3 6
" or
:BBset *.js 12
" etc.
Ctrl + Shift + ArrowUp   : add current buffer from current collection
Ctrl + Shift + ArrowDown : remove current buffer from current collection
```

Then use keyboard mappings to navigate it. I.e.

Go to previous buffer in list: <kbd>Ctrl+Shift+Left</kbd>

List buffers :BBls

etc.

---

It keeps, updates and use a dictionary of buffer lists.

```
 {
     default:   [1, 3 ,6],
     some_list: [1, 8 , 12],
     another:   [17, 4, 19]
 }

```

See `doc/BBUF.txt` for full help.

https://github.com/Termplexed/BBUF/blob/master/doc/BBUF.txt
