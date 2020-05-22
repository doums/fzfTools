" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:fzfGitLogSel")
  finish
endif
let g:fzfGitLogSel = 1

let s:prevWinId = 0
let s:script = findfile("bin/git_log_sel.sh", &runtimepath)
let s:jobRunning = 0
let s:bufNr = -1

function git_log_sel#SetScript()
  let s:script = findfile("bin/git_log_sel.sh", &runtimepath)
endfunction

function FzfToolsGitLogSelOnExit(jobId, exitStatus, ...)
  let s:jobRunning = 0
  quit
  call win_gotoid(s:prevWinId)
  if has("nvim")
    execute s:bufNr.'bdelete!'
  endif
  let list = readfile('/tmp/nvim/fzfTools_git_log_sel')
  if a:exitStatus != 0
    call s:PrintErr(get(list, 0, "something went wrong"))
    call s:ResetVariables()
    return
  endif
  call s:ResetVariables()
endfunction

function s:ResetVariables()
  let s:prevWinId = 0
  let s:jobRunning = 0
  let s:bufNr = -1
endfunction

function s:GetSelection()
  let start = getpos("'<")[1]
  let end = getpos("'>")[1]
  if start > end
    let tmp = start
    let start = end
    let end = tmp
  endif
  return [start, end]
endfunction

function git_log_sel#GitLogSel()
  if s:jobRunning
    return
  endif
  let s:jobRunning = 1
  let command = s:script
  let selection = s:GetSelection()
  let command = s:script." ".selection[0]." ".selection[1]." ".bufname()
  echom command
  let s:prevWinId = win_getid()
  let h = float2nr(floor(&lines*0.50))
  let tabMod = 0
  if h > 9
    bo new
  else
    tabnew
    let tabMod = 1
  endif
  let s:bufNr = bufnr()
  call setbufvar(s:bufNr, "&filetype", "fzfTools")
  if has("nvim")
    call termopen(command, { "on_exit": "FzfToolsGitLogSelOnExit" })
  else
    call term_start(command, {
          \ "curwin": 1,
          \ "term_name": "fzfTools",
          \ "exit_cb": "FzfToolsGitLogSelOnExit",
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
