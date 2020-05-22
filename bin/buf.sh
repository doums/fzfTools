#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set -eE

dir=/tmp/nvim
dest=$dir/fzfTools_buf

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

trap on_trap ERR

if ! fzf --version &> /dev/null; then
  printf "%s\n" "fzf not found" > $dest
  exit 1
fi

if [ "$#" -ne 2 ]; then
  printf "%s\n" "two arguments expected" > $dest
  exit 1
fi

fzf_output=$(echo -e "${2//$HOME/\~}" \
| fzf \
--prompt="buf " \
--header="${1//$HOME/\~}" \
--no-info \
--expect=ctrl-s,ctrl-v,ctrl-t \
| awk '{print $1}')

if [ -z "$fzf_output" ]; then
  exit 0
fi

mapfile -t array <<< "$fzf_output"

case "${array[0]}" in
  ctrl-s) mode="hSplit" ;;
  ctrl-v) mode="vSplit" ;;
  ctrl-t) mode="tab" ;;
  *) mode="default" ;;
esac

printf "%s\n" "$mode" > $dest
printf "%s\n" "${array[1]}" >> $dest
