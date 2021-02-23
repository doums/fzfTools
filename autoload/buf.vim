" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists("g:fzfBuf")
  finish
endif
let g:fzfBuf = 1

let s:fzf_prompt = 'buf '
let s:fzf_command = 'fzf --no-info'
let s:tmpfile = ''

let g:fzf_maps = {
      \  'ctrl-s': 'sbuffer',
      \  'ctrl-v': 'vertical sbuffer',
      \  'ctrl-t': 'tabedit',
      \}

let s:save_cpo = &cpo
set cpo&vim

let s:buffers = []
let s:script = findfile("bin/buf.sh", &runtimepath)

function! s:fzf_keys()
  let keys = ''
  for key in keys(g:fzf_maps)
    let keys .= key.','
  endfor
  return keys
endfunction

function buf#SetScript()
  let s:script = findfile("bin/buf.sh", &runtimepath)
endfunction

function s:OnExit(job, exitStatus)
  let list = readfile(s:tmpfile)
  if a:exitStatus == 1
    echom 'No match'
    return
  elseif a:exitStatus == 2
    call fzfTools#PrintErr('Error')
    return
  elseif a:exitStatus == 130
    return
  endif
  if a:exitStatus != 0
    call fzfTools#PrintErr('Exit status unknown')
    return
  endif
  if empty(list)
    return
  endif
  echom len(list)
  let mode=get(list, 0, '')
  echom mode
  let selected = get(list, 1)
  if !empty(selected)
    let splitted = split(selected)
    let bufnr = splitted[0]
    let file = splitted[-1]
    echom bufnr
    for buffer in s:buffers
      if buffer.number == bufnr
        if buffer.displayed && mode == ''
          call win_gotoid(buffer.windowsId[0])
        else
          if mode == ''
            execute 'buffer '.bufnr
          elseif mode == 'hSplit'
            execute 'sbuffer '.bufnr
          elseif mode == 'vSplit'
            execute 'vertical sbuffer '.bufnr
          elseif mode == 'tab'
            execute 'tabnew'
            execute 'buffer '.bufnr
          endif
        endif
        break
      endif
    endfor
  endif
  let s:buffers = []
  let s:tmpfile = ''
endfunction

function s:GetBufsInfo()
  let buffers = []
  let currentBuf = ""
  for buffer in getbufinfo({'buflisted': 1})
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
            \ 'displayed': !empty(buffer.windows),
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
  let s:tmpfile = tempname()
  let bufsInfo = s:GetBufsInfo()
  let s:buffers = bufsInfo.buffers
  let serializedBufs = s:SerializeBufs()
  let command = 'echo -e "'.serializedBufs.'" | '.s:fzf_command.' --header="'.bufsInfo.currentBuf.'" --prompt="'.s:fzf_prompt.'" --expect="'.s:fzf_keys().'" > '.s:tmpfile
  echom command
  let options = { 'command': command, 'callback': funcref("s:OnExit"), 'name': 'buf' }
  if exists('g:fzfTools') && has_key(g:fzfTools, 'buf')
    let options.layout = g:fzfTools.buf
  endif
  call oterm#spawn(options)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
