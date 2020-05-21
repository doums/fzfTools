#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set -e

dir=/tmp/nvim
dest=$dir/fzfTools_git_log_sel

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

if [ ! $# -eq 3 ]; then
  printf "%s\n" "three arguments expected" > $dest
  exit 1
fi

git log -L "$1,$2:$3" --date=format:%c --abbrev-commit 2> $dest
