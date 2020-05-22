#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set -e

on_trap () {
  if [ "$?" -eq 130 ] && [[ "$BASH_COMMAND" =~ "fzf" ]]; then
    exit 0
  fi
}

trap on_trap ERR

dir=/tmp/nvim
dest=$dir/fzfTools_git_log

if [ -e $dest ]; then
  rm $dest
  touch $dest
elif [ -d $dir ]; then
  touch $dest
else
  mkdir $dir
  touch $dest
fi

if ! fzf --version &> /dev/null; then
  printf "%s\n" "fzf not found" > $dest
  exit 1
fi

if ! git --version &> /dev/null; then
  printf "%s\n" "git not found" > $dest
  exit 1
fi

git status > /dev/null 2> $dest

case $# in
  0)
    git log --oneline --decorate=short | fzf \
      --preview="git show --color=always --abbrev-commit --pretty=medium --date=format:%c {1}" \
      --preview-window=right:70%:noborder \
      --header="git log"
  ;;
  1) git log -p --date=format:%c --abbrev-commit -- "$1";;
  3) git log -L "$1,$2:$3" --date=format:%c --abbrev-commit 2> $dest;;
  *)
    printf "%s\n" "wrong arguments" > $dest
    exit 1
  ;;
esac

echo -e "\n"
read -rsN 1 -p "press any key to quit... "
