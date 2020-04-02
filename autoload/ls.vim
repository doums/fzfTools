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

function ls#Tapi_Ls(bufNumber, json)
  let s:apiCalled = 1
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

function ls#OnLsEnds(job, exitStatus)
  let s:jobRunning = 0
  if a:exitStatus != 0 && a:exitStatus != 130
    call s:ResetVariables()
    return
  endif
  if a:exitStatus == 130
    let s:apiCalled = 1
  endif
  call win_gotoid(s:prevWinId)
  call s:ExecuteCommands()
endfunction

function s:ExecuteCommands()
  if !s:jobRunning && s:apiCalled
    execute "bd! ".s:termBuf
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
      echohl ErrorMsg | echo a:1." is not a directory" | echohl None
      call s:ResetVariables()
      return
    endif
    let command = s:script." ".directory
  endif
  let s:termBuf = term_start(command, {
        \ "term_name": "Ls",
        \ "term_api": "ls#Tapi_Ls",
        \ "term_rows": float2nr(floor(&lines*0.25)),
        \ "exit_cb": "ls#OnLsEnds",
        \ "term_kill": "SIGKILL"
        \ })
  call setbufvar(s:termBuf, "&filetype", "fzfLs")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
