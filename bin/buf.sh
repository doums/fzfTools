#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set -eE

send_to_vim () {
  printf '%b["call", "Tapi_fzfToolsBuf", %s]%b' "\e]51;" "$1" "\07"
}

on_trap () {
  if [ "$?" -eq 130 ] && [[ "$BASH_COMMAND" =~ "fzf_output" ]]; then
    send_to_vim "{\"mode\": \"\", \"selected\": \"\"}"
    exit 0
  fi
  send_to_vim "{\"error\": \"an error occurred in $0, line $1\"}"
}

trap 'on_trap "$LINENO"' ERR

if ! fzf --version &> /dev/null; then
  send_to_vim "{\"error\": \"fzf not found\"}"
  exit 1
fi

if [ "$#" -ne 2 ]; then
  send_to_vim "{\"error\": \"two arguments expected\"}"
  exit 1
fi

fzf_output=$(echo -e "${2//$HOME/\~}" \
| fzf \
--prompt="buf " \
--header="${1//$HOME/\~}" \
--no-info \
--expect=ctrl-s,ctrl-v,ctrl-t \
| awk '{print $1}')

mapfile -t array <<< "$fzf_output"

case "${array[0]}" in
  ctrl-s) mode="hSplit" ;;
  ctrl-v) mode="vSplit" ;;
  ctrl-t) mode="tab" ;;
  *) mode="default" ;;
esac

send_to_vim "{\"mode\": \"$mode\", \"selected\": \"${array[1]}\"}"