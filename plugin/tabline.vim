"------------------------------------------------------------------------------"
" Name:   tabline.vim
" Author: Luke Davis (lukelbd@gmail.com)
" Date:   2018-09-03
" A simple, minimal, black-and-white tabline that helps keep focus on the
" content and syntax coloring in the *document*, and accounts for long
" filenames and many open tabs.
"------------------------------------------------------------------------------
" Autocommand
" WARNING: For some reason checktime % does not trigger autocmd but
" checktime without arguments does.
scriptencoding utf-8
augroup shell_changed
  au!
  au BufReadPost,BufWritePost,BufNewFile * let b:file_changed_shell = 0
  au InsertLeave,TextChanged * silent! checktime
  au FileChangedShellPost * let b:file_changed_shell = 1
augroup END

" Autoload functions
command! -nargs=0 SmartWrite call tabline#smart_write()

" Default settings
if ! exists('g:tabline_charmax')
  let g:tabline_charmax = 12  " maximum characters for filename
endif
if ! exists('g:tabline_ftignore')
  let g:tabline_ftignore = [
    \ 'qf', 'vim-plug', 'help', 'diff', 'man',
    \ 'fugitive', 'nerdtree', 'tagbar', 'codi'
    \ ]
endif

" Hijacked from Tabline function, and modified
function! Tabline()
  " Iterate through tabs
  let tabstrings = []  " put strings in list
  let tabtexts = []  " actual text on screen
  for i in range(tabpagenr('$'))
    " Get 'primary' panel in tab, ignore 'helper' panels even if they are in focus
    let tabstring = ''
    let tabtext = ''
    let tab = i + 1
    let buflist = tabpagebuflist(tab)
    for b in buflist
      if index(g:tabline_ftignore, getbufvar(b, '&ft')) == -1
        let bufnr = b  " the 'primary' panel
        break
      elseif b == buflist[-1]  " e.g. entire tab is a help window
        let bufnr = b
      endif
    endfor
    if tab == tabpagenr()
      let g:bufmain = bufnr
    endif
    let bufname = bufname(bufnr) " actual name

    " Start the tab string
    let tabstring .= '%' . tab . 'T' " start 'tab' here; denotes edges of highlight groups and clickable area
    let tabstring .= (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#') " the # encodes string with either highlight group
    let tabtext .= ' ' . tab . '' " prefer zero-indexing

    " File name or placeholder if empty
    let fname = fnamemodify(bufname, ':t')
    if len(fname) - 2 > g:tabline_charmax
      let offset = len(fname) - g:tabline_charmax
      if offset % 2 == 1 | let offset += 1 | endif
      let fname = '·'.fname[offset/2:len(fname)-offset/2].'·' " … use this maybe
    endif
    let tabtext .= (bufname !=# '' ? '|'. fname . ' ' : '|? ')

    " Modification marker
    let bufmodified = getbufvar(bufnr, '&mod')
    if bufmodified
      let tabtext .= '[+] '
    endif

    " Modified on disk
    let changed = getbufvar(bufnr, 'file_changed_shell')
    if type(changed) == 0 && changed  " exists and is 1
      let tabtext .= '[!] '
    endif

    " Add stuff to lists
    let tabstrings += [tabstring . tabtext]
    let tabtexts += [tabtext]
  endfor

  " Modify if too long
  let prefix = ''
  let suffix = ''
  let tabstart = 1 " will modify this as delete tabs
  let tabend = tabpagenr('$') " same
  let tabpage = tabpagenr() " continually test position relative to tabstart/tabend
  while len(join(tabtexts, '')) + len(prefix) + len(suffix) > &columns " replace leading/trailing tabs with dots in meantime
    if tabend-tabpage > tabpage-tabstart " VIM lists are zero-indexed, end-inclusive
      let tabstrings = tabstrings[:-2]
      let tabtexts = tabtexts[:-2]
      let suffix = '···'
      let tabend -= 1 " decrement; have blotted out one tab on right
    else
      let tabstrings = tabstrings[1:]
      let tabtexts = tabtexts[1:]
      let prefix = '···'
      let tabstart += 1 " increment; have blotted out one tab on left
    endif
  endwhile

  " Return final version
  return prefix . join(tabstrings,'') . suffix . '%#TabLineFill#'
endfunction

" Settings and highlight groups
set showtabline=1 tabline=%!Tabline()
hi TabLine     ctermfg=White ctermbg=Black cterm=None
hi TabLineFill ctermfg=White ctermbg=Black cterm=None
hi TabLineSel  ctermfg=Black ctermbg=White cterm=None

