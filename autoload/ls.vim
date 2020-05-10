" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:fzfLs")
  finish
endif
let g:fzfLs = 1

let s:prevWinId = 0
let s:fileCommands = []
let s:script = findfile("bin/ls.sh", &runtimepath)
let s:jobRunning = 0
let s:bufNr = -1

function ls#SetScript()
  let s:script = findfile("bin/ls.sh", &runtimepath)
endfunction

function FzfToolsLsOnExit(jobId, exitStatus, ...)
  let s:jobRunning = 0
  quit
  call win_gotoid(s:prevWinId)
  if has("nvim")
    execute s:bufNr.'bdelete!'
  endif
  let list = readfile('/tmp/nvim/fzfTools_ls')
  if a:exitStatus != 0
    call s:PrintErr(get(list, 0, "empty"))
    call s:ResetVariables()
    return
  endif
  if empty(list)
    call s:ResetVariables()
    return
  endif
  let mode=get(list, 0, "default")
  call remove(list, 0)
  for file in list
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
  for command in s:fileCommands
    execute command
  endfor
  call s:ResetVariables()
endfunction

function s:ResetVariables()
  let s:prevWinId = 0
  let s:fileCommands = []
  let s:jobRunning = 0
  let s:bufNr = -1
endfunction

function ls#Ls(...)
  if s:jobRunning
    return
  endif
  let s:jobRunning = 1
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
  let s:prevWinId = win_getid()
  let h = float2nr(floor(&lines*0.30))
  let tabMod = 0
  if h > 5
    bo new
  else
    tabnew
    let tabMod = 1
  endif
  let s:bufNr = bufnr()
  call setbufvar(s:bufNr, "&filetype", "fzfTools")
  if has("nvim")
    call termopen(command, { "on_exit": "FzfToolsLsOnExit" })
  else
    call term_start(command, {
          \ "curwin": 1,
          \ "term_name": "fzfTools",
          \ "exit_cb": "FzfToolsLsOnExit",
          \ "term_finish": "close",
          \ "term_kill": "SIGKILL"
          \ })
  endif
  if !tabMod
    execute "resize ".h
  endif
  startinsert
endfunction

function s:PrintErr(msg)
  echohl ErrorMsg
  echom a:msg
  echohl None
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
