" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists('g:fzfTools_plugin')
  finish
endif
let g:fzfTools_plugin = 1

let s:save_cpo = &cpo
set cpo&vim

if !executable('fzf')
  call fzfTools#printerr('fzfTools requires fzf to be installed on your system')
  finish
endif

command -nargs=? -complete=dir Ls call fzfTools#ls(<f-args>)
noremap <silent> <unique> <script> <Plug>Ls <SID>LsMap
noremap <SID>LsMap :Ls<CR>

command Buf call fzfTools#buf()
noremap <silent> <unique> <script> <Plug>Buf <SID>BufMap
noremap <SID>BufMap :Buf<CR>

command -nargs=? -complete=file GitLog call fzfTools#gitlog('file', <f-args>)
noremap <silent> <unique> <script> <Plug>FGitLog <SID>GitLogMap
noremap <SID>GitLogMap :GitLog<CR>

command -range GitLogSel call fzfTools#gitlog('selection')
noremap <silent> <unique> <script> <Plug>GitLogSel <SID>GitLogSelMap
noremap <SID>GitLogSelMap :GitLogSel<CR>

command Reg call fzfTools#Reg()

let &cpo = s:save_cpo
unlet s:save_cpo
