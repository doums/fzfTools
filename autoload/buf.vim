" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists('g:fzf_buf_autoload')
  finish
endif
let g:fzf_buf_autoload = 1

let s:save_cpo = &cpo
set cpo&vim

let s:fzf_prompt = 'buf '
let s:fzf_command = 'fzf --no-info'
let s:changed_symbol = '+'
let s:buffers = []
let s:tmpfile = ''
let s:bufnr = ''

let g:fzf_keys = {
      \  'split': 'ctrl-s',
      \  'vsplit': 'ctrl-v',
      \  'tab': 'ctrl-t',
      \  'delete': 'ctrl-x',
      \}

function! s:reset()
  let s:buffers = []
  let s:tmpfile = ''
  let s:bufnr = ''
endfunction

function! s:fzf_keys()
  let keys = ''
  for key in values(g:fzf_keys)
    let keys .= key.','
  endfor
  return keys
endfunction

function! s:get_mode(fzf_key)
  for [key, value] in items(g:fzf_keys)
    if a:fzf_key == value
      return key
    endif
  endfor
  return ''
endfunction

function! s:on_exit(job, status)
  let lines = readfile(s:tmpfile)
  if a:status == 1
    echom 'No match'
    call s:reset()
    return
  elseif a:status == 2
    call fzfTools#PrintErr('Error')
    call s:reset()
    return
  elseif a:status == 130
    call s:reset()
    return
  endif
  if a:status != 0
    call fzfTools#PrintErr('Exit status unknown')
    call s:reset()
    return
  endif
  if empty(lines)
    call s:reset()
    return
  endif
  let mode = s:get_mode(get(lines, 0))
  let selected = get(lines, 1)
  if !empty(selected)
    let split = split(selected)
    let bufnr = split[0]
    let file = split[-1]
    for buffer in s:buffers
      if buffer.number == bufnr
        if buffer.displayed && mode == ''
          call win_gotoid(buffer.windowsId[0])
        else
          if mode == ''
            execute 'buffer '.bufnr
          elseif mode == 'split'
            execute 'sbuffer '.bufnr
          elseif mode == 'vsplit'
            execute 'vertical sbuffer '.bufnr
          elseif mode == 'tab'
            execute 'tabnew'
            execute 'buffer '.bufnr
          elseif mode == 'delete'
            try
              execute 'bdelete '.bufnr
            catch
              call fzfTools#PrintErr('The buffer is modified and not saved')
            endtry
          endif
        endif
        break
      endif
    endfor
  endif
  call s:reset()
endfunction

function! s:get_buf_info()
  let buffers = []
  let current_buf = ''
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
            \ 'windowsId': buffer.windows,
            \ 'changed': buffer.changed
            \ })
    else
      let current_buf = buffer.bufnr
      if buffer.changed
        let current_buf .= ' '.s:changed_symbol
      else
        let current_buf .= '  '
      endif
      let current_buf .= ' '.name
    endif
  endfor
  return {'current_buf': current_buf, 'buffers': buffers}
endfunction

function! s:serialize_bufs()
  let buffers = ''
  let index = 0
  while index < len(s:buffers)
    let buffer = s:buffers[index]
    if buffer.changed
    endif
    let buffers .= buffer.number
    if buffer.changed
      let buffers .= ' '.s:changed_symbol
    else
      let buffers .= '  '
    endif
    let buffers .= ' '..buffer.name
    if index < len(s:buffers) - 1
      let buffers = buffers.'\n'
    endif
    let index += 1
  endwhile
  return buffers
endfunction

function buf#buf()
  if !empty(s:bufnr)
    return
  endif
  let s:tmpfile = tempname()
  let bufs_info = s:get_buf_info()
  let s:buffers = bufs_info.buffers
  let serialized = s:serialize_bufs()
  let command = 'echo -e "'.serialized.'" | '.s:fzf_command.' --header="'.bufs_info.current_buf.'" --prompt="'.s:fzf_prompt.'" --expect="'.s:fzf_keys().'" > '.s:tmpfile
  let options = { 'command': command, 'callback': funcref('s:on_exit'), 'name': 'buf' }
  if exists('g:fzfTools') && has_key(g:fzfTools, 'buf')
    let options.layout = g:fzfTools.buf
  endif
  let s:bufnr = oterm#spawn(options)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
