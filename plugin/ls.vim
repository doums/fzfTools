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
let s:lsScript = findfile("bin/ls.sh", &runtimepath)

function Tapi_Ls(bufNumber, json)
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
endfunction

function OnLsEnds(job, exitStatus)
  execute "q"
  call win_gotoid(s:prevWinId)
  if a:exitStatus == 0
    for command in s:fileCommands
      execute command
    endfor
  endif
  let s:termBuf = 0
  let s:prevWinId = 0
  let s:fileCommands = []
endfunction

function s:Ls(...)
  let s:prevWinId = win_getid()
  let command = s:lsScript
  if a:0 == 1
    let command = s:lsScript." ".expand(a:1)
  endif
  let s:termBuf = term_start(command, {
        \ "term_name": "Ls",
        \ "term_api": "Tapi_Ls",
        \ "term_rows": float2nr(floor(&lines*0.25)),
        \ "exit_cb": "OnLsEnds",
        \ "term_kill": "SIGKILL",
        \ "term_finish": "close"
        \ })
  call setbufvar(s:termBuf, "&filetype", "fzfLs")
endfunction

command -nargs=? -complete=dir Ls call <SID>Ls(<f-args>)
noremap <silent> <unique> <script> <Plug>Ls <SID>LsMap
noremap <SID>LsMap :Ls<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
