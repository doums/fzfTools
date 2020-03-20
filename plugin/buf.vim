" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:fzfBuf")
  finish
endif
let g:fzfBuf = 1

function Tapi_Buf(bufNumber, json)
  echom "Tapi_Buf called!"
  let s:selectedBuffer=a:json.selected
  echom buffer
endfunction

function OnBufEnds(job, exitStatus)
  " execute "q"
  if a:exitStatus != 0
    call win_gotoid(s:prevWinId)
  else
    for buffer in s:buffer
      if buffer.number == s:selectedBuffer
        if buffer.displayed
          call win_gotoid(buffer.windowsId[0])
        else
          call win_gotoid(s:prevWinId)
          execute "buffer "
        endif
      endif
    endfor
  endif
  let s:termBuf = 0
  let s:prevWinId = 0
  let s:buffers = []
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
      echom "added a \\n"
      let buffers = buffers.."\n"
    endif
    let index += 1
  endwhile
  echom buffers
  return buffers
endfunction

function s:Buf()
  let s:prevWinId = win_getid()
  let bufsInfo = s:GetBufsInfo()
  let s:buffers = bufsInfo.buffers
  echom bufsInfo
  let serializedBufs = s:SerializeBufs()
  let command = s:bufScript..' "'..bufsInfo.currentBuf..'" "'..serializedBufs..'"'
  let s:termBuf = term_start(command, {
        \ "term_name": "Buf",
        \ "term_api": "Tapi_Buf",
        \ "term_rows": float2nr(floor(&lines*0.25)),
        \ "exit_cb": "OnBufEnds",
        \ "term_kill": "SIGKILL",
        \ })
        " \ "term_finish": "close"
  call setbufvar(s:termBuf, "&filetype", "fzfBuf")
endfunction

command Buf call <SID>Buf()
noremap <silent> <unique> <script> <Plug>Buf <SID>BufMap
noremap <SID>BufMap :Buf<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
