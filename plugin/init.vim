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
  setlocal nonumber
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
  if has("nvim")
    autocmd TermOpen,BufEnter fzfTools call <SID>InitTermWin()
    autocmd BufLeave,TermClose fzfTools call <SID>RestoreWinOpt()
  else
    autocmd TerminalWinOpen,BufEnter fzfTools call <SID>InitTermWin()
    autocmd BufLeave,BufDelete fzfTools call <SID>RestoreWinOpt()
  endif
  autocmd VimEnter,DirChanged * call fzfTools#SetScripts()
augroup END

command -nargs=? -complete=dir Ls call fzfTools#Ls(<f-args>)
noremap <silent> <unique> <script> <Plug>Ls <SID>LsMap
noremap <SID>LsMap :Ls<CR>

command Buf call fzfTools#Buf()
noremap <silent> <unique> <script> <Plug>Buf <SID>BufMap
noremap <SID>BufMap :Buf<CR>

command -nargs=? -complete=file GitLog call fzfTools#GitLog(<f-args>)
noremap <silent> <unique> <script> <Plug>FGitLog <SID>GitLogMap
noremap <SID>GitLogMap :GitLog<CR>

command -range GitLogSel call fzfTools#GitLogSel()
noremap <silent> <unique> <script> <Plug>GitLogSel <SID>GitLogSelMap
noremap <SID>GitLogSelMap :GitLogSel<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
