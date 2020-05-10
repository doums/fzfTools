#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set -eE

dir=/tmp/nvim
dest=$dir/fzfTools_ls

if [ -e $dest ]; then
  rm $dest
  touch $dest
elif [ -d $dir ]; then
  touch $dest
else
  mkdir $dir
  touch $dest
fi

on_trap () {
  if [ "$?" -eq 130 ] && [[ "$BASH_COMMAND" =~ "fzf_output" ]]; then
    exit 0
  fi
}

trap 'on_trap "$LINENO"' ERR

if ! fzf --version &> /dev/null; then
  printf "%s\n" "fzf not found" > $dest
  exit 1
fi

if ! bat --version &> /dev/null; then
  printf "%s\n" "bat not found" > $dest
  exit 1
fi

if [ "$1" ]; then
  if [ "${1: -1:1}" = "/" ]; then
    directory="$1"
  else
    directory="$1/"
  fi
  cd "$1"
fi

path="$(pwd)"
path="${path//$HOME/\~}"
IFS='/' read -ra array <<< "$path"
prompt="${array[${#array[@]}-1]}"

fzf_output=$(fzf \
--multi \
--preview="bat --line-range :50 --color always {}" \
--expect=ctrl-s,ctrl-v,ctrl-t \
--preview-window=right:70%:noborder \
--prompt="$prompt ")

mapfile -t array <<< "$fzf_output"

case "${array[0]}" in
  ctrl-s) mode="hSplit" ;;
  ctrl-v) mode="vSplit" ;;
  ctrl-t) mode="tab" ;;
  *) mode="default" ;;
esac

printf "%s\n" "$mode" > $dest

unset 'array[0]'

for index in "${!array[@]}"; do
  file=""
  if [ "$directory" ]; then
    file=$directory
  fi
  file+="${array[index]}"
  printf "%s\n" "$file" >> $dest
done
