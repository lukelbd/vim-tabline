# Tabline
This vim plugin provides a simple black-and-white "tabline" with some handy features. The tabline will look something like the following:

```
··· 2|name2.ext  3|·ry_long_name.e·  4|name4.ext ···
```

The directory names are always omitted. If the file name is more than `g:tabline_charmax` characters long (the default is `12`), the beginning and end of the tab name are truncated and replaced with `·`.
If there are too many tabs open for the window width, the leading and trailing names
surrounding the current tab are truncated and replaced with `···`.

This plugin always derives tab names from the "main file." That is, the tab name is the name of the first window in the tab that does not belong to a filetype in the `g:tabline_ftignore` list (the default is `['qf', 'vim-plug', 'help', 'diff', 'man', 'fugitive', 'nerdtree', 'tagbar', 'codi']`).

# Installation
Install with your favorite [plugin manager](https://vi.stackexchange.com/questions/388/what-is-the-difference-between-the-vim-plugin-managers).
I highly recommend the [vim-plug](https://github.com/junegunn/vim-plug) manager. To install with vim-plug, add
```
Plug 'lukelbd/vim-tabline'
```
to your `~/.vimrc`.

