Tabline
=======

This vim plugin provides a simple black-and-white "tabline" that looks something
like this:

```
··· 2|name2.ext  3|·ry_long_name.e·  4|name4.ext ···
```

Each tab title is determined as follows:

* The "main" file name is always used, i.e. the first window in the tab
  whose filetype is not present in the `g:tabline_ftignore` list (defaults to
  `['qf', 'vim-plug', 'help', 'diff', 'man', 'fugitive', 'nerdtree', 'tagbar', 'codi']`).
  The file directory is always omitted.
* If the file name is more than `g:tabline_charmax` characters long (defaults to `12`),
  the ends of the title are truncated and replaced with `·`.
* If the "main" buffer has been modified since the file was last saved, a `[+]` is
  appended to the tab title.
* If the "main" file has changed on the disk since it was last loaded into the buffer,
  a `[!]` is appended to the tab title.
* If there are too many tabs open for the window width, the leading and trailing tab
  titles surrounding the *current* tab are truncated and replaced with `···`.

This plugin also defines a `:SmartWrite` command that should be used to write files
instead of `:write`. The `:SmartWrite` command prevents writing to disk if the buffer
was not changed. It also fixes a vim bug where if you *reject* saving a file that was
modified on disk, the `BufWritePost` autocommand is still triggered and the `[!]` goes
away, even though the changes were not loaded or overwritten.

Installation
============

Install with your favorite [plugin manager](https://vi.stackexchange.com/q/388/8084).
I highly recommend the [vim-plug](https://github.com/junegunn/vim-plug) manager.
To install with vim-plug, add
```
Plug 'lukelbd/vim-tabline'
```
to your `~/.vimrc`.
