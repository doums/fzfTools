" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists("g:fzfLs")
  finish
endif
let g:fzfLs = 1

let s:save_cpo = &cpo
set cpo&vim

let s:fileCommands = []
let s:script = findfile("bin/ls.sh", &runtimepath)

function ls#SetScript()
  let s:script = findfile("bin/ls.sh", &runtimepath)
endfunction

function s:OnExit(job, exitStatus)
  let list = readfile('/tmp/nvim/fzfTools_ls')
  if a:exitStatus != 0
    call fzfTools#PrintErr(get(list, 0, "empty"))
    return
  endif
  if empty(list)
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
  let s:fileCommands = []
endfunction

function ls#Ls(...)
  let command = s:script
  if a:0 == 1
    let directory = expand(a:1)
    if !isdirectory(directory)
      call fzfTools#PrintErr(a:1." is not a directory")
      return
    endif
    let command = s:script." ".directory
  endif
  let options = { 'command': command, 'callback': funcref("s:OnExit"), 'name': 'ls' }
  if exists('g:fzfTools') && has_key(g:fzfTools, 'ls')
    let options.layout = g:fzfTools.ls
  endif
  call oterm#spawn(options)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
