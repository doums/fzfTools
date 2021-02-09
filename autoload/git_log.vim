" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists("g:fzfGitLog")
  finish
endif
let g:fzfGitLog = 1

let s:save_cpo = &cpo
set cpo&vim

let s:script = findfile("bin/git_log.sh", &runtimepath)

function git_log#SetScript()
  let s:script = findfile("bin/git_log.sh", &runtimepath)
endfunction

function s:OnExit(job, exitStatus)
  let list = readfile('/tmp/nvim/fzfTools_git_log')
  if a:exitStatus != 0
    call fzfTools#PrintErr(get(list, 0, "something went wrong"))
    return
  endif
endfunction

function git_log#GitLog(...)
  let command = s:script
  if a:0 == 1
    let command = s:script." ".expand(a:1)
  endif
  let options = { 'command': command, 'callback': funcref("s:OnExit"), 'name': 'gitlog' }
  if exists('g:fzfTools') && has_key(g:fzfTools, 'gitlog')
    let options.layout = g:fzfTools.gitlog
  endif
  call oterm#spawn(options)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
