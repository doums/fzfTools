" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:fzfTools")
  finish
endif
let g:fzfTools = 1

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

function fzfTools#Buf()
  call buf#Buf()
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

function fzfTools#SetScripts()
  call ls#SetScript()
  call buf#SetScript()
  call git_log#SetScript()
  call git_log_sel#SetScript()
endfunction

function fzfTools#IsRunning()
  return s:jobRunning
endfunction

function FzfToolsOnExit(jobId, exitStatus, ...)
  let s:jobRunning = 0
  quit
  call win_gotoid(s:prevWinId)
  if has("nvim")
    execute s:bufNr.'bdelete!'
  endif
  call s:callback(a:exitStatus)
  let s:prevWinId = 0
  let s:jobRunning = 0
  let s:bufNr = -1
  let s:callback = 0
endfunction

function fzfTools#NewTerm(command, Callback)
  if s:jobRunning
    return
  endif
  let s:jobRunning = 1
  let s:callback = a:Callback
  let s:prevWinId = win_getid()
  let h = float2nr(floor(&lines*0.40))
  let tabMod = 0
  if h > 9
    bo new fzfTools
  else
    tabnew fzfTools
    let tabMod = 1
  endif
  let s:bufNr = bufnr()
  call setbufvar(s:bufNr, "&filetype", "fzfTools")
  if has("nvim")
    call termopen(a:command, { "on_exit": "FzfToolsOnExit" })
    file fzfTools
  else
    call term_start(a:command, {
          \ "curwin": 1,
          \ "term_name": "fzfTools",
          \ "exit_cb": "FzfToolsOnExit",
          \ "term_finish": "close",
          \ "term_kill": "SIGKILL"
          \ })
  endif
  if !tabMod
    execute "resize ".h
  endif
  startinsert
endfunction

function fzfTools#PrintErr(msg)
  echohl ErrorMsg
  echom a:msg
  echohl None
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
