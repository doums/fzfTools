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
  call fzf_utils#printerr('fzfTools requires fzf to be installed on your system')
  let &cpo = s:save_cpo
  unlet s:save_cpo
  finish
endif

command -nargs=? -complete=dir Ls call fzf_ls#spawn(<f-args>)
noremap <silent> <unique> <script> <Plug>Ls <SID>LsMap
noremap <SID>LsMap :Ls<CR>

command Buffers call fzf_buffers#spawn()
noremap <silent> <unique> <script> <Plug>Buffers <SID>BuffersMap
noremap <SID>BuffersMap :Buffers<CR>

command -nargs=? -complete=file GitLog call fzf_gitlog#spawn('file', <f-args>)
noremap <silent> <unique> <script> <Plug>FGitLog <SID>GitLogMap
noremap <SID>GitLogMap :GitLog<CR>

command -range GitLogSel call fzf_gitlog#spawn('selection')
noremap <silent> <unique> <script> <Plug>GitLogSel <SID>GitLogSelMap
noremap <SID>GitLogSelMap :GitLogSel<CR>

command Registers call fzf_registers#spawn()
noremap <silent> <unique> <script> <Plug>Registers <SID>RegistersMap
noremap <SID>RegistersMap :Registers<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
