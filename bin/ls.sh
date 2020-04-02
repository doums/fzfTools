#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set -eE

send_to_vim () {
  printf '%b["call", "Tapi_fzfToolsLs", %s]%b' "\e]51;" "$1" "\07"
}

on_trap () {
  if [ "$?" -eq 130 ] && [[ "$BASH_COMMAND" =~ "fzf_output" ]]; then
    send_to_vim "{\"mode\": \"\", \"selection\": []}"
    exit 0
  fi
  send_to_vim "{\"error\": \"an error occurred in $0, line $1\"}"
}

trap 'on_trap "$LINENO"' ERR

if ! fzf --version &> /dev/null; then
  send_to_vim "{\"error\": \"fzf not found\"}"
  exit 1
fi

if ! bat --version &> /dev/null; then
  send_to_vim "{\"error\": \"bat not found\"}"
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

unset 'array[0]'

for index in "${!array[@]}"; do
  selection+="\""
  if [ "$directory" ]; then
    selection+=$directory
  fi
  selection+="${array[index]}\""
  if [ "$index" -lt "${#array[@]}" ]; then
    selection+=", "
  fi
done

send_to_vim "{\"mode\": \"$mode\", \"selection\": [$selection]}"