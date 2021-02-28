" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists('g:fzf_registers_autoload')
  finish
endif
let g:fzf_registers_autoload = 1

let s:save_cpo = &cpo
set cpo&vim

let s:fzf_header = 'registers'
let s:fzf_command = "fzf --preview='echo {2..}' --preview-window=right:70%:noborder:wrap --header='".s:fzf_header."' | awk '{print $1}'"

let s:tmpfile = ''
let s:bufnr = ''

function! s:reset()
  let s:tmpfile = ''
  let s:bufnr = ''
endfunction

function! s:on_exit(job, status) abort
  if !fzf_utils#check_exit_status(a:status)
    call s:reset()
    return
  endif
  let lines = readfile(s:tmpfile)
  if empty(lines)
    call s:reset()
    return
  endif
  let regname = lines[0][1]
  call setreg('"', getreg(regname, 1))
  call setreg('+', getreg(regname, 1))
  call s:reset()
endfunction

function! s:addreg(list, register)
  let value = getreg(a:register, 1)
  if !empty(value)
    let value = substitute(strtrans(value), '\n\|\r\|\e\|\\n\|\\r\|\\e', '^J', 'g')
    let [str_match, start, end] = matchstrpos(value, '\\\+"')
    if start != -1
      if (strlen(str_match) - 1) % 2 == 0
        let splitted = split(value, '\zs')
        call insert(splitted, '\', start)
        let value = join(splitted, '')
      endif
    endif
    let value = substitute(value, '\(\\\)\@123<!"', '\\"', 'g')
    call add(a:list, '\"'.escape(a:register, '"').'  '.value)
  endif
endfunction

function! fzf_registers#spawn()
  if !empty(s:bufnr)
    return
  endif
  let s:tmpfile = tempname()
  let registers = []
  " unnamed register
  call s:addreg(registers, '"')
  " numbered registers 0-9
  for i in range(10)
    call s:addreg(registers, i)
  endfor
  " named registers a to z
  for c in range(97, 122)
    call s:addreg(registers, nr2char(c))
  endfor
  " small delete register
  call s:addreg(registers, '-')
  " read-only registers
  call s:addreg(registers, ':')
  call s:addreg(registers, '.')
  call s:addreg(registers, '%')
  " alternate file register
  call s:addreg(registers, '#')
  " expression rfegister
  call s:addreg(registers, '=')
  " selection registers
  call s:addreg(registers, '*')
  call s:addreg(registers, '+')
  " black hole register
  call s:addreg(registers, '_')
  " last search pattern register
  call s:addreg(registers, '/')
  let command = 'echo -e "'.join(registers, '\n').'" | '.s:fzf_command.' > '.s:tmpfile
  let options = { 'command': command, 'callback': funcref("s:on_exit"), 'name': 'registers' }
  if exists('g:fzfTools') && has_key(g:fzfTools, 'registers')
    let options.layout = g:fzfTools.registers
  endif
  let s:bufnr = oterm#spawn(options)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
