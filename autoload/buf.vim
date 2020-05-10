" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:fzfBuf")
  finish
endif
let g:fzfBuf = 1

let s:prevWinId = 0
let s:buffers = []
let s:script = findfile("bin/buf.sh", &runtimepath)
let s:jobRunning = 0
let s:bufNr = -1

function buf#SetScript()
  let s:script = findfile("bin/buf.sh", &runtimepath)
endfunction

function FzfToolsBufOnExit(job, exitStatus, ...)
  let s:jobRunning = 0
  quit
  call win_gotoid(s:prevWinId)
  if has("nvim")
    execute s:bufNr.'bdelete!'
  endif
  let list = readfile('/tmp/nvim/fzfTools_buf')
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
  let selected = get(list, 1)
  if !empty(selected)
    for buffer in s:buffers
      if buffer.number == selected
        if buffer.displayed && mode == "default"
          call win_gotoid(buffer.windowsId[0])
        else
          call win_gotoid(s:prevWinId)
          if mode == "default"
            execute "buffer ".selected
          elseif mode == "hSplit"
            execute "sbuffer ".selected
          elseif mode == "vSplit"
            execute "vertical sbuffer ".selected
          elseif mode == "tab"
            execute "tabnew"
            execute "buffer ".selected
          endif
        endif
        break
      endif
    endfor
  endif
  call s:ResetVariables()
endfunction

function s:ResetVariables()
  let s:prevWinId = 0
  let s:buffers = []
  let s:jobRunning = 0
  let s:bufNr = -1
endfunction

function s:GetBufsInfo()
  let buffers = []
  let currentBuf = ""
  for buffer in getbufinfo({'buflisted': 1, 'bufloaded': 1})
    let name = buffer.name
    if empty(buffer.name)
      let name = '-'
    else
      let name = bufname(buffer.bufnr)
    endif
    if bufnr() != buffer.bufnr
      call add(buffers, {
            \ 'number': buffer.bufnr,
            \ 'name': name,
            \ 'displayed': !buffer.hidden,
            \ 'windowsId': buffer.windows
            \ })
    else
      let currentBuf = buffer.bufnr.." "..name
    endif
  endfor
  return {'currentBuf': currentBuf, 'buffers': buffers}
endfunction

function s:SerializeBufs()
  let buffers = ""
  let index = 0
  while index < len(s:buffers)
    let buffer = s:buffers[index]
    let buffers = buffers..buffer.number.." "..buffer.name
    if index < len(s:buffers) - 1
      let buffers = buffers.."\n"
    endif
    let index += 1
  endwhile
  return buffers
endfunction

function buf#Buf()
  if s:jobRunning
    return
  endif
  let s:jobRunning = 1
  let s:prevWinId = win_getid()
  let bufsInfo = s:GetBufsInfo()
  let s:buffers = bufsInfo.buffers
  let serializedBufs = s:SerializeBufs()
  let command = s:script..' "'..bufsInfo.currentBuf..'" "'..serializedBufs..'"'
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
    call termopen(command, { "on_exit": "FzfToolsBufOnExit" })
  else
    call term_start(command, {
          \ "curwin": 1,
          \ "term_name": "fzfTools",
          \ "exit_cb": "FzfToolsBufOnExit",
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
