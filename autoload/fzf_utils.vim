" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists("g:fzf_utils_autoload")
  finish
endif
let g:fzf_utils_autoload = 1

let s:save_cpo = &cpo
set cpo&vim

function! fzf_utils#check_exit_status(status)
  if a:status == 1
    echom 'No match'
    return 0
  elseif a:status == 2
    call fzf_utils#printerr('Error')
    return 0
  elseif a:status == 130
    return 0
  endif
  if a:status != 0
    call fzf_utils#printerr('Exit status unknown')
    return 0
  endif
  return 1
endfunction

function! fzf_utils#printerr(msg)
  echohl ErrorMsg
  echom a:msg
  echohl None
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
