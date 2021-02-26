" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists("g:fzf_reg_autoload")
  finish
endif
let g:fzf_reg_autoload = 1

let s:save_cpo = &cpo
set cpo&vim

let s:fzf_command = "fzf --preview='echo {2..}' --preview-window=right:70%:noborder:wrap --prompt='reg ' | awk '{print $1}'"

let s:tempfile = ''

function! s:on_exit(job, exitStatus)
  " let list = readfile(s:tempfile)
  echom a:exitStatus
  if a:exitStatus != 0
    call fzf_utils#printerr('error')
    return
  endif
endfunction

function! s:addreg(list, register)
  let value = getreg(a:register, 1)
  if !empty(value)
    let value = substitute(value, '\n\|\r\|\e\|\\n\|\\r', '^J', 'g')
    " let value = substitute(value, '\\\@123<!''', '''\\''''', 'g')
    let value = substitute(value, '''\(\\''''\)\@!', '''\\''''', 'g')
    " let value = escape(value, "'")
    echom value
    call add(a:list, '"'.a:register.'  '.value)
  endif
endfunction

function! fzf_reg#spawn()
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
  let command = "echo -e '".join(registers, '\n')."' | ".s:fzf_command
  echom command
  let options = { 'command': command, 'callback': funcref("s:on_exit"), 'name': 'reg' }
  if exists('g:fzfTools') && has_key(g:fzfTools, 'reg')
    let options.layout = g:fzfTools.reg
  endif
  call oterm#spawn(options)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
