## fzfTools

:hammer: A [neovim](https://neovim.io/)/[vim](https://www.vim.org/) plugin that provides a lightweight collection of tools that uses [fzf](https://github.com/junegunn/fzf).

### what's the difference with [fzf.vim](https://github.com/junegunn/fzf.vim)?
As @junegunn (the original author of fzf and fzf.vim) said:
> fzf in itself is not a Vim plugin, and the official repository only provides the basic wrapper function for Vim and it's up to the users to write their own Vim commands with it.

Junegunn did a great job providing us with fzf.vim (and a awesome job for fzf) and I thank him (like many people I think)!\
But after inspecting the code behind this plugin, I realized that it offers to support a plethora of things like Windows, different versions of vim, neovim etc...\
In addition, it offers a high level of customization, lots of predefined commands, mappings etc...\
So the code is pretty huge (it's normal).

But personally, I only use nvim/vim on my Arch Linux and using a plugin like this just seemed overkill for my needs.\
So I decided to follow the initial advise above and write my own plugin in a more [kiss'ish](https://en.wikipedia.org/wiki/KISS_principle) way.

### prerequisites
- [fzf](https://github.com/junegunn/fzf)
- [bat](https://github.com/sharkdp/bat)

### install

If you use a plugin manager, follow the traditional way.

For example with [vim-plug](https://github.com/junegunn/vim-plug) add this in `.vimrc`/`init.vim`
```
Plug 'doums/fzfTools'
```

then run in vim
```
:source $MYVIMRC
:PlugInstall
```

If you use vim package `:h packages`.

### tools

For both of the following tools you can open the selected item(s) in several ways.\
`enter` in the current window\
`ctrl-s` horizontal split\
`ctrl-v` vertical split\
`ctrl-t` in a new tab

#### Ls
List the files in the current directory or in the given directory and open the one(s) you need.

usage:
- **`Ls` command**
```
:Ls [directory]
```
- **`<Plug>Ls` mapping**
```
nmap <C-s> <Plug>Ls
```

#### Buf
List the loaded and listed buffers and goto/open the one you need.

usage:
- **`Buf` command**
```
:Buf
```
- **`<Plug>Buf` mapping**
```
nmap <C-b> <Plug>Buf
```

#### GitLog
Show commit logs (optionally for a given file).

usage:
- **`GitLog` command**
```
:GitLog [file]
```
- **`<Plug>FGitLog` mapping**
```
nmap <C-g> <Plug>GitLog
```

#### GitLogSel
Trace the git evolution of the current selection.

usage:
- **`GitLogSel` command**
```
:GitLogSel
```
- **`<Plug>GitLogSel` mapping**
```
vmap <C-g> <Plug>GitLogSel
```

### credits
junegunn for fzf

### license
Mozilla Public License 2.0
