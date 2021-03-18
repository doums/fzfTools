## fzfTools

:hammer: A [neovim](https://neovim.io/)/[vim](https://www.vim.org/) plugin that provides a lightweight collection of tools that uses [fzf](https://github.com/junegunn/fzf).

### what's the difference with [fzf.vim](https://github.com/junegunn/fzf.vim)?
As @junegunn (the original author of fzf and fzf.vim) said:
> fzf in itself is not a Vim plugin, and the official repository only provides the basic wrapper function for Vim and it's up to the users to write their own Vim commands with it.

Junegunn did a great job providing us with fzf.vim (and a awesome job for fzf) and I thank him (like many people I think)!\
But after inspecting the code behind this plugin, I realized that it offers to support a plethora of things like Windows, different versions of vim, neovim etc...\
In addition, it offers a high level of customization, lots of predefined commands, mappings etc...\
So the code is pretty huge (it's normal).

But personally, I only use nvim on my Arch Linux and using a plugin like this just seemed overkill for my needs.\
So I decided to follow the initial advise above and write my own plugin in a more kiss'ish way.

### prerequisites
- [fzf](https://github.com/junegunn/fzf)
- [oterm](https://github.com/doums/oterm)

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

### config

The config is optional.\
You can provide an oterm layout for each tool:
```
" .vimrc/init.vim

let g:fzfTools = {
      \  'ls': { 'down': 40, 'min': 10 },
      \  'buffers': { 'down': 40, 'min': 10 },
      \  'registers': { 'down': 40, 'min': 10 },
      \  'gitlog': { 'tab': 1 },
      \  'gitlogsel': { 'tab': 1 },
      \}
```
By default `g:oterm` layout is used.

### tools

For Ls and Buffers tools you can open the selected item(s) in several ways:\
`enter` in the current window\
`ctrl-s` horizontal split\
`ctrl-v` vertical split\
`ctrl-t` in a new tab\
`ctrl-x` remove the buffer from the buffer list

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

#### Buffers
List the loaded and listed buffers and goto/open the one you need.

usage:
- **`Buffers` command**
```
:Buffers
```
- **`<Plug>Buffers` mapping**
```
nmap <C-b> <Plug>Buffers
```

#### Registers
List the registers and pick the one that will become the current register.\
The unnamed `""` and selection `"+` registers will take the value of the selected one.\
Its content will be used for the next put commands.

usage:
- **`Registers` command**
```
:Registers
```
- **`<Plug>Registers` mapping**
```
nmap <A-p> <Plug>Registers
```

#### GitLog
Show commit logs (optionally for a given file).

usage:
- **`GitLog` command**
```
:GitLog [file]
```
- **`<Plug>GitLog` mapping**
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
- **`<Plug>SGitLog` mapping**
```
vmap <C-g> <Plug>SGitLog
```

### credits
junegunn for fzf

### license
Mozilla Public License 2.0
