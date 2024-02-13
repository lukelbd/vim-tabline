Tabline
=======

Vim plugin providing a simple black-and-white "tabline" that looks something
like this:

```
··· 2|file2.ext [+]  3|file3.ext  4|·ry_long_file_name.e· [!]  5|file5.ext [~][:] ···
```

Each tab title is determined as follows:

* The "main" file name is always used, i.e. the first window in the tab
  whose filetype is not present in `g:tabline_skip_filetypes`
  (default `['diff', 'help', 'man', 'qf']`). The directory is always omitted.
* If the file name has more than `g:tabline_maxlength` characters
  (default `13`), the tab title is truncated and the ends are replaced with `·`.
* If there are too many tabs open for the window width, the leading and trailing tab
  titles surrounding the *current* tab are truncated and replaced with `···`.
* If the "main" file buffer has been modified since the file was last saved, a `[+]`
  is appended to the tab title (similar to the default behavior).
* If the "main" file was changed on the disk since it was last loaded into the buffer,
  a `[!]` is appended to the tab title (uses `au FileChangedShell`).
* If the "main" file is in a git repository and has unstaged changes, a `[~]` is
  appended to the tab title (uses `au User FugitiveChanged`).
* If the "main" file is in a git repository and has uncommitted staged changes, a
  `[:]` is appended to the tab title (uses `au User FugitiveChanged`).

The staged changes flag `[~]` requires the plugins [vim-fugitive](https://github.com/tpope/vim-fugitive)
and [vim-gitgutter](https://github.com/airblade/vim-gitgutter).

Installation
============

Install with your favorite [plugin manager](https://vi.stackexchange.com/q/388/8084).
I highly recommend the [vim-plug](https://github.com/junegunn/vim-plug) manager.
To install with vim-plug, add
```
Plug 'lukelbd/vim-tabline'
```
to your `~/.vimrc`.
