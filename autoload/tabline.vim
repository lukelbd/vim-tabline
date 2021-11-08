"-----------------------------------------------------------------------------"
" Related command for saving the file
"-----------------------------------------------------------------------------"
" Note: If the file is unmodified :update should do nothing
" Note: Prevents vim bug where cancelling the save in the confirmation
" prompt still triggers BufWritePost and resets b:file_changed_shell.
function! tabline#write() abort
  let changed_shell = exists('b:file_changed_shell') ? b:file_changed_shell : 0
  update
  if &l:modified && changed_shell && !b:file_changed_shell
    let b:file_changed_shell = 1
  endif
endfunction
