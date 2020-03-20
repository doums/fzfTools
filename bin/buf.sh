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

echo "$1"
echo "$2"

buffer=$(echo -e "${2//$HOME/\~}" \
| fzf --prompt="buf " --header="${1//$HOME/\~}" \
| awk '{print $1}')

json_body="{\"selected\": \"$buffer\"}"
printf '%b["call", "Tapi_Buf", %s]%b' "\e]51;" "$json_body" "\07"