" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists("g:fzf_utils_autoload")
  finish
endif
let g:fzf_utils_autoload = 1

let s:save_cpo = &cpo
set cpo&vim

function! fzf_utils#printerr(msg)
  echohl ErrorMsg
  echom a:msg
  echohl None
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
