" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists("g:fzfTools_autoload")
  finish
endif
let g:fzfTools_autoload = 1

let s:save_cpo = &cpo
set cpo&vim

function! fzfTools#ls(...)
  if a:0 == 1
    call ls#ls(a:1)
  else
    call ls#ls()
  endif
endfunction

function! fzfTools#buf()
  call buf#buf()
endfunction

function! fzfTools#gitlog(...)
  if a:0 > 1 && a:1 == 'file'
    call git_log#gitlog('file', a:2)
  elseif a:0 > 0 && a:1 == 'selection'
    call git_log#gitlog('selection')
  else
    call git_log#gitlog()
  endif
endfunction

function! fzfTools#Reg()
  call reg#Reg()
endfunction

function! fzfTools#printerr(msg)
  echohl ErrorMsg
  echom a:msg
  echohl None
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
