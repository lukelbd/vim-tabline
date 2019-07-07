# Tabline
This VIM plugin provides a simple black-and-white "tabline" with some handy features. The tabline will look something like the following:

```
··· 2|name2.ext  3|·ry_long_name.e·  4|name4.ext ···
```

The directory name is omitted from tab name. If the file name is more than 12 characters
long, the beginning and end of the name are truncated and replaced with `·` characters.
If there are too many tabs open for the window width, the leading and trailing tabs
surrounding the current tab are truncated and replaced with `···`. And critically, tab titles
are always derived from the "main file" filename -- that is, the tab title is determined
from all the windows in the tab, and windows belonging to certain ignored filetypes
(e.g. `help`) are not used for the title.

See the source code for details.

# Installation
Install with your favorite [plugin manager](https://vi.stackexchange.com/questions/388/what-is-the-difference-between-the-vim-plugin-managers).
I highly recommend the [`vim-plug`](https://github.com/junegunn/vim-plug) manager,
in which case you can install this plugin by adding
```
Plug 'lukelbd/vim-tabline'
```
to your `~/.vimrc`.

