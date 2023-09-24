"------------------------------------------------------------------------------
" Author: Luke Davis (lukelbd@gmail.com)
" Date:   2018-09-03
" A minimal, informative, black-and-white tabline that helps keep focus on the
" content in each window and accounts for long filenames and many open tabs.
"------------------------------------------------------------------------------
" Autocommand
" Warning: For some reason checktime % does not trigger autocmd but
" checktime without arguments does.
" Warning: For some reason FileChangedShellPost causes warning message to
" be shown even with silent! checktime, but FileChangedShell does not.
scriptencoding utf-8
augroup tabline_filechanged
  au!
  au BufEnter,InsertEnter,TextChanged * silent! checktime
  au BufReadPost,BufWritePost,BufNewFile * let b:tabline_filechanged = 0
  au FileChangedShell * call setbufvar(expand('<afile>'), 'tabline_filechanged', 1)
augroup END

" Deprecated
if exists('g:tabline_charmax')
  let g:tabline_maxlength = g:tabline_charmax
endif
if exists('g:tabline_ftignore')
  let g:tabline_skip_filetypes = g:tabline_ftignore
endif

" Default settings
if !exists('g:tabline_maxlength')
  let g:tabline_maxlength = 12
endif
if !exists('g:tabline_skip_filetypes')
  let g:tabline_skip_filetypes = ['diff', 'help', 'man', 'qf']
endif

" Get automatic tabline colors
" Note: This is needed for GUI vim color schemes since they do not use cterm codes.
" Also some schemes use named colors so have to convert into hex by appending '#'.
" See: https://stackoverflow.com/a/27870856/4970632
" See: https://vi.stackexchange.com/a/20757/8084
function! s:default_color(code, ...) abort
  let hex = synIDattr(hlID('Normal'), a:code . '#')
  if empty(hex) || hex[0] !=# '#' | return | endif  " unexpected output
  let shade = a:0 ? a:1 ? 0.3 : 0.0 : 0.0  " shade toward neutral gray
  let color = '#'  " default hex color
  for idx in range(1, 5, 2)
    " vint: -ProhibitUsingUndeclaredVariable
    let value = str2nr(hex[idx:idx + 1], 16)
    let value = value - shade * (value - 128)
    let color .= printf('%02x', float2nr(value))
  endfor
  return color
endfunction


" Generate tabline text
function! Tabline()
  let tabstrings = []  " tabline string
  let tabtexts = []  " displayed text
  for tnr in range(1, tabpagenr('$'))
    " Get primary panel in tab ignoring popups
    let filt = "bufname(v:val)[0] !=# '!'"  " always ignore fzf complete windows
    let buflist = filter(tabpagebuflist(tnr), filt)
    let buflist = empty(buflist) ? tabpagebuflist(tnr) : buflist  " fall-back
    let tabtext = ' ' . tnr . ''
    let tabstring = '%' . tnr . 'T'  " edges of highlight groups and clickable area
    let tabstring .= tnr == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'
    for bufnr in buflist
      if index(g:tabline_skip_filetypes, getbufvar(bufnr, '&ft')) == -1
        break  " use this as 'primary' or else use the final one
      endif
    endfor

    " Create the tab with an updated file
    let bufname = bufname(bufnr)
    let fname = fnamemodify(bufname, ':t')
    if empty(fname)
      let fname = getbufvar(bufnr, '&filetype', '')
    endif
    if len(fname) - 2 > g:tabline_maxlength
      let offset = len(fname) - g:tabline_maxlength
      let offset += (offset % 2 == 1)
      let fname = '·' . fname[offset / 2: len(fname) - offset / 2] . '·'
    endif
    let tabtext .= empty(fname) ? '|? ' : '|' . fname . ' '

    " Add markers and update lists
    let modified = getbufvar(bufnr, '&modified')
    if modified
      let tabtext .= '[+] '
    endif
    let changed = getbufvar(bufnr, 'tabline_filechanged', 0)
    if changed
      let tabtext .= '[!] '
    endif
    let tabtexts += [tabtext]
    let tabstrings += [tabstring . tabtext]

    " Emit warning
    let warned = getbufvar(bufnr, 'tabline_warnchanged', 0)
    if !changed || !modified
      call setbufvar(bufnr, 'tabline_warnchanged', 0)
    elseif !warned
      echohl WarningMsg
      echo 'Warning: Modifying buffer that was changed on disk.'
      echohl None
      call setbufvar(bufnr, 'tabline_warnchanged', 1)
    endif
  endfor

  " Truncate if too long
  let prefix = ''
  let suffix = ''
  let tabstart = 1  " first tab shown
  let tabend = tabpagenr('$')  " last tab shown
  let tabpage = tabpagenr()
  while len(join(tabtexts, '')) + len(prefix) + len(suffix) > &columns
    if tabend - tabpage > tabpage - tabstart
      let tabstrings = tabstrings[:-2]
      let tabtexts = tabtexts[:-2]
      let suffix = '···'
      let tabend -= 1  " decrement, have blotted out one tab on right
    else
      let tabstrings = tabstrings[1:]
      let tabtexts = tabtexts[1:]
      let prefix = '···'
      let tabstart += 1  " increment, have blotted out one tab on left
    endif
  endwhile

  " Apply syntax colors and return string
  let s = has('gui_running') ? 'gui' : 'cterm'
  let flag = has('gui_running') ? '#be0119' : 'Red'  " copied from xkcd scarlet
  let black = has('gui_running') ? s:default_color('bg', 1) : 'Black'
  let white = has('gui_running') ? s:default_color('fg', 0) : 'White'
  exe 'highlight TabLine ' . s . 'fg=' . white . ' ' . s . 'bg=' . black . ' ' . s . '=None'
  exe 'highlight TabLineFill ' . s . 'fg=' . white . ' ' . s . 'bg=' . black . ' ' . s . '=None'
  exe 'highlight TabLineSel ' . s . 'fg=' . black . ' ' . s . 'bg=' . white . ' ' . s . '=None'
  return prefix . join(tabstrings,'') . suffix . '%#TabLineFill#'
endfunction

" Settings and highlight groups
set tabline=%!Tabline()
let &showtabline = &showtabline ? &showtabline : 1
