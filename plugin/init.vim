" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:fzfInit")
  finish
endif
let g:fzfInit = 1

function s:InitTermWin(file)
  if has("nvim")
    let ft = getbufvar(a:file, "&filetype")
    if ft != "fzfTools"
      return
    endif
  endif
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

function s:RestoreWinOpt(file)
  if has("nvim")
    let ft = getbufvar(a:file, "&filetype")
    if ft != "fzfTools"
      return
    endif
  endif
  let &laststatus = s:lastStatus
  let &showmode = s:showMode
  let &ruler = s:ruler
  let &showcmd = s:showCmd
  let &cmdheight = s:cmdHeight
endfunction

augroup fzfTools
  autocmd!
  if has("nvim")
    autocmd TermOpen,BufEnter */ls.sh*,*/buf.sh* call <SID>InitTermWin(expand("<afile>"))
    autocmd BufLeave,TermClose */ls.sh*,*/buf.sh* call <SID>RestoreWinOpt(expand("<afile>"))
  else
    autocmd TerminalWinOpen,BufEnter fzfTools call <SID>InitTermWin(expand("<afile>"))
    autocmd BufLeave,BufDelete fzfTools call <SID>RestoreWinOpt(expand("<afile>"))
  endif
  autocmd VimEnter,DirChanged * call fzfTools#SetScripts()
augroup END

command -nargs=? -complete=dir Ls call fzfTools#Ls(<f-args>)
noremap <silent> <unique> <script> <Plug>Ls <SID>LsMap
noremap <SID>LsMap :Ls<CR>

command Buf call fzfTools#Buf()
noremap <silent> <unique> <script> <Plug>Buf <SID>BufMap
noremap <SID>BufMap :Buf<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
