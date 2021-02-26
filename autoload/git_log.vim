" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists("g:fzf_git_log_autoload")
  finish
endif
let g:fzf_git_log_autoload = 1

let s:save_cpo = &cpo
set cpo&vim

let s:fzf_prompt = 'gitlog '
let s:fzf_command = 'git log --oneline --decorate=short | fzf '
      \.'--preview="git show --color --abbrev-commit --pretty=medium --date=format:%c {1}" '
      \.'--preview-window=right:70%:noborder '
      \.'--header="git log"'
let s:bufnr = ''

function! s:fzf_command_file(file)
  return 'git log --oneline --decorate=short --parents --diff-filter=a -- "'.a:file.'" | fzf '
        \.'--with-nth=3.. '
        \.'--preview="git show --color --abbrev-commit -s --pretty=medium --date=format:%c {1} '
        \.'&& echo -e \n '
        \.'&& git diff -p --color {2} {1} -- '.a:file.'" '
        \.'--preview-window=right:70%:noborder '
        \.'--header="git log '.a:file.'"'
endfunction

function! s:fzf_command_sel(start, end, file)
  return 'git log -L'.a:start.','.a:end.':'.a:file.' --date=format:%c --abbrev-commit'
endfunction

function! s:reset()
  let s:bufnr = ''
endfunction

function! s:on_exit(job, status)
  if a:status == 1
    echom 'No match'
    call s:reset()
    return
  elseif a:status == 2
    call fzfTools#printerr('Error')
    call s:reset()
    return
  elseif a:status == 130
    call s:reset()
    return
  endif
  if a:status != 0
    call fzfTools#printerr('Exit status unknown')
    call s:reset()
    return
  endif
  call s:reset()
endfunction

function! s:get_selection()
  let start = getpos("'<")[1]
  let end = getpos("'>")[1]
  if start > end
    let tmp = start
    let start = end
    let end = tmp
  endif
  return [start, end]
endfunction

function! git_log#gitlog(...)
  if !executable('git')
    call fzfTools#printerr('fzfTools requires git to be installed on your system')
    return
  endif
  if !empty(s:bufnr)
    return
  endif
  let command = s:fzf_command
  if a:0 == 2 && a:1 == 'file' && !empty(a:2)
    let command = s:fzf_command_file(expand(a:2))
  endif
  if a:0 == 1 && a:1 == 'selection'
    let [start, end] = s:get_selection()
    let command = s:fzf_command_sel(start, end, bufname())
  endif
  let options = { 'command': command, 'callback': funcref("s:on_exit"), 'name': 'gitlog' }
  if exists('g:fzfTools') && has_key(g:fzfTools, 'gitlog')
    let options.layout = g:fzfTools.gitlog
  endif
  let s:bufnr = oterm#spawn(options)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
