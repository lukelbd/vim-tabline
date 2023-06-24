"------------------------------------------------------------------------------
" Name:   tabline.vim
" Author: Luke Davis (lukelbd@gmail.com)
" Date:   2018-09-03
" A simple, minimal, black-and-white tabline that helps keep focus on the content
" in each window and accounts for long filenames and many open tabs.
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

" Autoload functions
command! -nargs=0 TablineWrite call tabline#write()

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

" Main function
function! Tabline()
  highlight TabLine ctermfg=White ctermbg=Black cterm=None
  highlight TabLineFill ctermfg=White ctermbg=Black cterm=None
  highlight TabLineSel ctermfg=Black ctermbg=White cterm=None
  let tabstrings = []  " tabline string
  let tabtexts = []  " displayed text
  for idx in range(tabpagenr('$'))
    " Get primary panel in tab ignoring popups
    let tnr = idx + 1
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
  return prefix . join(tabstrings,'') . suffix . '%#TabLineFill#'
endfunction

" Settings and highlight groups
set tabline=%!Tabline()
let &showtabline = &showtabline ? &showtabline : 1
