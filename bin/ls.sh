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

if [ "$1" ]; then
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
  selection+="\"$(pwd)/${array[index]}\""
  if [ "$index" -lt "${#array[@]}" ]; then
    selection+=", "
  fi
done

json_body="{\"mode\": \"$mode\", \"selection\": [$selection]}"
printf '%b["call", "Tapi_Ls", %s]%b' "\e]51;" "$json_body" "\07"