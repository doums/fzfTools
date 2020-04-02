" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:fzfLs")
  finish
endif
let g:fzfLs = 1

let s:termBuf = 0
let s:prevWinId = 0
let s:fileCommands = []
let s:script = findfile("bin/ls.sh", &runtimepath)
let s:jobRunning = 0
let s:apiCalled = 0

function ls#SetScript()
  let s:script = findfile("bin/ls.sh", &runtimepath)
endfunction

function Tapi_fzfToolsLs(bufNumber, json)
  let s:apiCalled = 1
  if exists("a:json.error")
    call s:PrintErr(a:json.error)
    call s:ResetVariables()
    return
  endif
  let mode=a:json.mode
  for file in a:json.selection
    if mode == "default"
      call add(s:fileCommands, "edit ".file)
    elseif mode == "hSplit"
      call add(s:fileCommands, "split ".file)
    elseif mode == "vSplit"
      call add(s:fileCommands, "vsplit ".file)
    elseif mode == "tab"
      call add(s:fileCommands, "tabedit ".file)
    endif
  endfor
  call s:ExecuteCommands()
endfunction

function FzfToolsLsOnExit(job, exitStatus)
  let s:jobRunning = 0
  call win_gotoid(s:prevWinId)
  if a:exitStatus != 0
    call s:ResetVariables()
    return
  endif
  call s:ExecuteCommands()
endfunction

function s:ExecuteCommands()
  if !s:jobRunning && s:apiCalled
    for command in s:fileCommands
      execute command
    endfor
    call s:ResetVariables()
  endif
endfunction

function s:ResetVariables()
  let s:termBuf = 0
  let s:prevWinId = 0
  let s:fileCommands = []
  let s:jobRunning = 0
  let s:apiCalled = 0
endfunction

function ls#Ls(...)
  if s:jobRunning
    return
  endif
  let s:jobRunning = 1
  let s:prevWinId = win_getid()
  let command = s:script
  if a:0 == 1
    let directory = expand(a:1)
    if !isdirectory(directory)
      call s:PrintErr(a:1." is not a directory")
      call s:ResetVariables()
      return
    endif
    let command = s:script." ".directory
  endif
  let s:termBuf = term_start(command, {
        \ "term_name": "Ls",
        \ "term_api": "Tapi_fzfToolsLs",
        \ "term_rows": float2nr(floor(&lines*0.25)),
        \ "exit_cb": "FzfToolsLsOnExit",
        \ "term_finish": "close",
        \ "term_kill": "SIGKILL"
        \ })
  call setbufvar(s:termBuf, "&filetype", "fzfLs")
endfunction

function s:PrintErr(msg)
  echohl ErrorMsg
  echom a:msg
  echohl None
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
