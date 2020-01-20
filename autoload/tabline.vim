"-----------------------------------------------------------------------------"
" Related command for saving the file
"-----------------------------------------------------------------------------"
" Note: This prevents vim bug where cancelling the save in the confirmation
" prompt still triggers BufWritePost.
function! tabline#smart_write() abort
  let changed = b:file_changed_shell
  update  " if file is unmodified this should do nothing
  if &l:modified && changed && ! b:file_changed_shell
    let b:file_changed_shell = 1
  endif
endfunction
