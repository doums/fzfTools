" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:fzfInit")
  finish
endif
let g:fzfInit = 1

function s:InitTermWin()
  execute "normal :\<BS>"
  execute "normal \<C-w>J"
  call term_setsize('', float2nr(floor(&lines*0.25)), 0)
  let s:lastStatus = &laststatus
  let s:showMode = &showmode
  let s:ruler = &ruler
  let s:showCmd = &showcmd
  let s:cmdHeight = &cmdheight
  set laststatus=0
  set noshowmode
  set noruler
  set noshowcmd
  set cmdheight=1
endfunction

function s:RestoreWinOpt()
  let &laststatus = s:lastStatus
  let &showmode = s:showMode
  let &ruler = s:ruler
  let &showcmd = s:showCmd
  let &cmdheight = s:cmdHeight
endfunction

augroup fzfTools
  autocmd!
  autocmd TerminalWinOpen,BufEnter Ls,Buf call <SID>InitTermWin()
  autocmd BufLeave,BufDelete Ls,Buf call <SID>RestoreWinOpt()
augroup END

command -nargs=? -complete=dir Ls call fzfTools#Ls(<f-args>)
noremap <silent> <unique> <script> <Plug>Ls <SID>LsMap
noremap <SID>LsMap :Ls<CR>

command Buf call fzfTools#Buf()
noremap <silent> <unique> <script> <Plug>Buf <SID>BufMap
noremap <SID>BufMap :Buf<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
