" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists('g:fzf_ls_autoload')
  finish
endif
let g:fzf_ls_autoload = 1

let s:save_cpo = &cpo
set cpo&vim

let s:fzf_prompt = 'ls '
let s:fzf_preview_command = executable('bat') ? 'COLORTERM=truecolor bat --line-range :50 --color=always' : 'cat'
let s:fzf_command = 'fzf --multi --preview-window=right:70%:noborder --prompt="'.s:fzf_prompt.'" --preview="'.s:fzf_preview_command.' {}"'
let s:tmpfile = ''
let s:bufnr = ''

let s:actions = {
      \  'split': 'ctrl-s',
      \  'vsplit': 'ctrl-v',
      \  'tab': 'ctrl-t',
      \}

function! s:reset()
  let s:tmpfile = ''
  let s:bufnr = ''
endfunction

function! s:fzf_keys()
  let keys = ''
  for key in values(s:actions)
    let keys .= key.','
  endfor
  return keys
endfunction

function! s:get_mode(fzf_key)
  for [key, value] in items(s:actions)
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
  call remove(lines, 0)
  if mode == ''
    execute 'edit '.lines[0]
  elseif mode == 'split'
    execute 'split '.lines[0]
  elseif mode == 'vsplit'
    execute 'vsplit '.lines[0]
  elseif mode == 'tab'
    execute 'tabedit '.lines[0]
  endif
  for file in lines[1:]
    execute 'badd '.file
  endfor
  call s:reset()
endfunction

function! ls#ls(...)
  if !empty(s:bufnr)
    return
  endif
  let s:tmpfile = tempname()
  if a:0 == 1
    let directory = expand(a:1)
    if !isdirectory(directory)
      call fzfTools#PrintErr(a:1.' is not a directory')
      return
    endif
  endif
  let command = s:fzf_command.' --expect="'.s:fzf_keys().'" > '.s:tmpfile
  let options = { 'command': command, 'callback': funcref('s:on_exit'), 'name': 'ls' }
  if exists('g:fzfTools') && has_key(g:fzfTools, 'ls')
    let options.layout = g:fzfTools.ls
  endif
  let s:bufnr = oterm#spawn(options)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
