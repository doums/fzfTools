" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists("g:fzfInit")
  finish
endif
let g:fzfInit = 1

let s:save_cpo = &cpo
set cpo&vim

augroup fzfTools
  autocmd!
  autocmd VimEnter,DirChanged * call fzfTools#SetScripts()
augroup END

command -nargs=? -complete=dir Ls call fzfTools#Ls(<f-args>)
noremap <silent> <unique> <script> <Plug>Ls <SID>LsMap
noremap <SID>LsMap :Ls<CR>

command Buf call fzfTools#buf()
noremap <silent> <unique> <script> <Plug>Buf <SID>BufMap
noremap <SID>BufMap :Buf<CR>

command -nargs=? -complete=file GitLog call fzfTools#GitLog(<f-args>)
noremap <silent> <unique> <script> <Plug>FGitLog <SID>GitLogMap
noremap <SID>GitLogMap :GitLog<CR>

command -range GitLogSel call fzfTools#GitLogSel()
noremap <silent> <unique> <script> <Plug>GitLogSel <SID>GitLogSelMap
noremap <SID>GitLogSelMap :GitLogSel<CR>

command Reg call fzfTools#Reg()

let &cpo = s:save_cpo
unlet s:save_cpo
