
A Vim plugin to render help when working with collection of buffers.

Typically:

:BBset 1 3 6
:BBset *.js 12

etc.

Then use keyboard mappings to navigate it. I.e.

Go to previous buffer in list Ctrl+Shift+Left

List buffers :BBls

etc.

It keeps, updates and use a dictionary of buffer lists.


 {
     default:   [1, 3 ,6],
     some_list: [1, 8 , 12],
     another:   [17, 4, 19]
 }



See doc/BBUF.txt for full help.

https://github.com/Termplexed/BBUF
