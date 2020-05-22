" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:fzfGitLogSel")
  finish
endif
let g:fzfGitLogSel = 1

let s:script = findfile("bin/git_log.sh", &runtimepath)

function git_log_sel#SetScript()
  let s:script = findfile("bin/git_log.sh", &runtimepath)
endfunction

function s:OnExit(exitStatus)
  let list = readfile('/tmp/nvim/fzfTools_git_log')
  if a:exitStatus != 0
    call fzfTools#PrintErr(get(list, 0, "something went wrong"))
    return
  endif
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
  if fzfTools#IsRunning()
    return
  endif
  let command = s:script
  let selection = s:GetSelection()
  if selection[0] == 0 || selection[1] == 0
    call fzfTools#PrintErr("invalid selection")
    return
  endif
  let command = s:script." ".selection[0]." ".selection[1]." ".bufname()
  let Callback = function("s:OnExit")
  call fzfTools#NewTerm(command, Callback)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
