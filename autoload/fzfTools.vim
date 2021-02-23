" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists("g:fzfTools_autoload")
  finish
endif
let g:fzfTools_autoload = 1

let s:save_cpo = &cpo
set cpo&vim

let s:prevWinId = 0
let s:jobRunning = 0
let s:callback = 0
let s:bufNr = -1

function fzfTools#Ls(...)
  if a:0 == 1
    call ls#Ls(a:1)
  else
    call ls#Ls()
  endif
endfunction

function fzfTools#buf()
  call buf#buf()
endfunction

function fzfTools#GitLog(...)
  if a:0 == 1
    call git_log#GitLog(a:1)
  else
    call git_log#GitLog()
  endif
endfunction

function fzfTools#GitLogSel()
  call git_log_sel#GitLogSel()
endfunction

function fzfTools#Reg()
  call reg#Reg()
endfunction

function fzfTools#SetScripts()
  call ls#SetScript()
  call git_log#SetScript()
  call git_log_sel#SetScript()
endfunction

function fzfTools#PrintErr(msg)
  echohl ErrorMsg
  echom a:msg
  echohl None
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
