" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:fzfBuf")
  finish
endif
let g:fzfBuf = 1

let s:termBuf = 0
let s:prevWinId = 0
let s:buffers = []
let s:responde = 0
let s:bufScript = 0

function buf#Tapi_Buf(bufNumber, json)
  let s:response = {'mode': a:json.mode,
        \ 'selected': a:json.selected}
endfunction

function buf#OnBufEnds(job, exitStatus)
  execute "q"
  let selected = s:response.selected
  let mode = s:response.mode
  if a:exitStatus != 0 || empty(selected)
    call win_gotoid(s:prevWinId)
  else
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
  let s:bufScript = 0
  let s:termBuf = 0
  let s:prevWinId = 0
  let s:buffers = []
  let s:response = 0
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
  let s:bufScript = findfile("bin/buf.sh", &runtimepath)
  let s:prevWinId = win_getid()
  let bufsInfo = s:GetBufsInfo()
  let s:buffers = bufsInfo.buffers
  let serializedBufs = s:SerializeBufs()
  let command = s:bufScript..' "'..bufsInfo.currentBuf..'" "'..serializedBufs..'"'
  let s:termBuf = term_start(command, {
        \ "term_name": "Buf",
        \ "term_api": "buf#Tapi_Buf",
        \ "term_rows": float2nr(floor(&lines*0.25)),
        \ "exit_cb": "buf#OnBufEnds",
        \ "term_kill": "SIGKILL",
        \ "term_finish": "close"
        \ })
  call setbufvar(s:termBuf, "&filetype", "fzfBuf")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
