
" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:fzfTools")
  finish
endif
let g:fzfTools = 1

function fzfTools#Ls(...)
  if a:0 == 1
    call ls#Ls(a:1)
  else
    call ls#Ls()
  endif
endfunction

function fzfTools#Buf()
  call buf#Buf()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
