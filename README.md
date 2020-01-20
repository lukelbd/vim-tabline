# Tabline
This vim plugin provides a simple black-and-white "tabline" with some handy features. The tabline will look something like the following:

```
··· 2|name2.ext  3|·ry_long_name.e·  4|name4.ext ···
```

* The directory is always omitted from the tab title.
* The tab title is always derived the "main file", i.e. the first window in the tab that does not belong to a filetype in the `g:tabline_ftignore` list (the default is `['qf', 'vim-plug', 'help', 'diff', 'man', 'fugitive', 'nerdtree', 'tagbar', 'codi']`).
* If the file name is more than `g:tabline_charmax` characters long (the default is `12`), the ends of the tab title are truncated and replaced with `·`.
* If there are too many tabs open for the window width, the leading and trailing tab titles
surrounding the *current* tab are truncated and replaced with `···`.
* If the buffer has been modified, a ``[+]`` is appended to the tab title.
* If the file was modified on disk since it was last loaded into the buffer, a ``[!]`` is appended to the tab title.

This plugin also defines a `:SmartWrite` command that should be used to write files
instead of ``:write``. This prevents writing to disk if the buffer was not changed.
It also fixes a vim bug where if you *reject* saving a file that was modified on disk,
the `BufWritePost` autocommand is still triggered and the ``[!]`` goes away, even
though the changes were not loaded or overwritten.

# Installation
Install with your favorite [plugin manager](https://vi.stackexchange.com/questions/388/what-is-the-difference-between-the-vim-plugin-managers).
I highly recommend the [vim-plug](https://github.com/junegunn/vim-plug) manager. To install with vim-plug, add
```
Plug 'lukelbd/vim-tabline'
```
to your `~/.vimrc`.

