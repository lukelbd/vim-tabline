"------------------------------------------------------------------------------
" Author: Luke Davis (lukelbd@gmail.com)
" Date:   2018-09-03
" A minimal, informative, black-and-white tabline that helps keep focus on the
" content in each window and accounts for long filenames and many open tabs.
"------------------------------------------------------------------------------
" File changed autocommand
" Warning: For some reason checktime % does not trigger autocmd but
" checktime without arguments does.
" Warning: For some reason FileChangedShellPost causes warning message to
" be shown even with silent! checktime, but FileChangedShell does not.
scriptencoding utf-8
augroup tabline_changed
  au!
  au BufEnter,InsertEnter,TextChanged * silent! checktime
  au BufReadPost,BufWritePost,BufNewFile * let b:tabline_filechanged = 0
  au FileChangedShell * call setbufvar(expand('<afile>'), 'tabline_filechanged', 1)
  au User FugitiveChanged call s:process_buffers(0)
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
  let g:tabline_maxlength = 13
endif
if !exists('g:tabline_skip_filetypes')
  let g:tabline_skip_filetypes = ['diff', 'help', 'man', 'qf']
endif

" Return default tabline colors
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

" Process gitgutter buffers
" Note: If g:gitgutter_async on then still might have delays updating unstaged
" changes flag, even with a force-update. This seems to be the best we can do.
" Note: This is needed so that [~] flag displays correctly across tabs. Otherwise
" does not update until navigating to buffers. Run whenever FugitiveChanged User
" autocommand fires, e.g. after :Git stage operations or FileChangedShellPost.
function! s:process_buffers(...) abort
  let force = a:0 ? a:1 : 0
  let git = getbufvar(bufnr('%'), 'git_dir', '')
  let base = fnamemodify(git, ':h')  " remove .git tail
  if empty(git) | return | endif
  if !exists('*gitgutter#process_buffer') | return | endif
  for tnr in range(1, tabpagenr('$'))  " iterate through each tab
    for bnr in tabpagebuflist(tnr)
      let name = fnamemodify(bufname(bnr), ':p')
      let igit = getbufvar(bnr, 'git_dir', '')
      if git ==# igit || name =~# '^' . base
        call gitgutter#process_buffer(bnr, force)
      endif
    endfor
  endfor
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
    for bnr in buflist
      let path = expand('#' . bnr . ':p')
      let type = getbufvar(bnr, '&filetype')
      if index(g:tabline_skip_filetypes, type) == -1
        break  " use this as 'primary' or else use the final one
      endif
    endfor

    " Create the tab with an updated file
    let blob = '^\x\{33}\(\x\{7}\)$'
    let path = fnamemodify(path, ':t')
    let path = substitute(path, blob, '\1', '')
    let none = empty(path) || path =~# '^!'
    if none  " display filetype instead of path
      let path = getbufvar(bnr, '&filetype', path)
    endif
    for nr in buflist  " settabvar() somehow interferes with visual mode iter#scroll
      call setbufvar(nr, 'tabline_bufnr', bnr)
    endfor
    if len(path) - 2 > g:tabline_maxlength
      let offset = len(path) - g:tabline_maxlength
      let offset += (offset % 2 == 1)
      let part = strcharpart(path, offset / 2, g:tabline_maxlength)
      let path = '·' . part . '·'
    endif
    let tabtext .= empty(path) ? '|? ' : '|' . path . ' '

    " Add markers and update lists
    let flags = []
    let changed = !none && getbufvar(bnr, 'tabline_filechanged', 0)
    let modified = !none && getbufvar(bnr, '&modified')
    if none || !exists('*gitgutter#hunk#summary')
      let unstaged = 0
    else
      let unstaged = len(filter(copy(gitgutter#hunk#summary(bnr)), 'v:val'))
    endif
    if modified
      call add(flags, '[+]')
    endif
    if unstaged
      call add(flags, '[~]')
    endif
    if changed
      call add(flags, '[!]')
    endif
    if !empty(flags)
      let tabtext .= join(flags, '') . ' '
    endif
    call add(tabtexts, tabtext)
    call add(tabstrings, tabstring . tabtext)

    " Emit warning
    let warned = getbufvar(bnr, 'tabline_warnchanged', 0)
    if !changed || !modified
      call setbufvar(bnr, 'tabline_warnchanged', 0)
    elseif !warned
      echohl WarningMsg
      echo 'Warning: Modifying buffer that was changed on disk.'
      echohl None
      call setbufvar(bnr, 'tabline_warnchanged', 1)
    endif
  endfor

  " Truncate if too long
  let prefix = ''
  let suffix = ''
  let tabstart = 1  " first tab shown
  let tabend = tabpagenr('$')  " last tab shown
  let tabpage = tabpagenr()
  while strwidth(prefix . join(tabtexts, '') . suffix) > &columns
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
  let tabline = s . 'fg=' . white . ' ' . s . 'bg=' . black . ' ' . s . '=None'
  let tablinesel = s . 'fg=' . black . ' ' . s . 'bg=' . white . ' ' . s . '=None'
  let tablinefill = s . 'fg=' . white . ' ' . s . 'bg=' . black . ' ' . s . '=None'
  exe 'highlight TabLine ' . tabline
  exe 'highlight TabLineSel ' . tablinesel
  exe 'highlight TabLineFill ' . tablinefill
  return prefix . join(tabstrings,'') . suffix . '%#TabLineFill#'
endfunction

" Settings and highlight groups
set tabline=%!Tabline()
let &showtabline = &showtabline ? &showtabline : 1
