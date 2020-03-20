#!/bin/bash

set -e

red="\e[38;5;1m"
bold="\e[1m"
reset="\e[0m"

if ! fzf --version &> /dev/null; then
  >&2 printf "%bThis script needs %bfzf%b%b to work.%b\n" \
  "$red" "$bold" "$reset" "$red" "$reset"
  exit 1
fi

if ! bat --version &> /dev/null; then
  >&2 printf "%bThis script needs %bbat%b%b to work.%b\n" \
  "$red" "$bold" "$reset" "$red" "$reset"
  exit 1
fi

if [ "$#" -ne 2 ]; then
  >&2 printf "%bThis script expects two arguments to work.%b\n" \
  "$red" "$reset"
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

json_body="{\"mode\": \"$mode\", \"selected\": \"${array[1]}\"}"
printf '%b["call", "Tapi_Buf", %s]%b' "\e]51;" "$json_body" "\07"