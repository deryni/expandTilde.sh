#!/bin/bash

expandPath() {
  local path
  local -a pathElements resultPathElements
  IFS=':' read -r -a pathElements <<<"$1"
  : "${pathElements[@]}"
  for path in "${pathElements[@]}"; do
    : "$path"
    case $path in
      "~+")
        path=$PWD
        ;;
      "~+"/*)
        path=$PWD/${path#"~+/"}
        ;;
      "~-")
        path=$OLDPWD
        ;;
      "~-"/*)
        path=$OLDPWD/${path#"~-/"}
        ;;
      "~")
        path=$HOME
        ;;
      "~"/*)
        path=$HOME/${path#"~/"}
        ;;
      "~"[0-9]|"~"[+-][0-9])
        num=${path#"~"}
        op=${num%%[0-9]*}
        num=${num#[+-]}
        local opath=$path
        if [ "${op:-+}" = "+" ]; then
          path=${DIRSTACK[@]: $num:1}
        else
          path=${DIRSTACK[@]: -($num+1):1}
        fi
        : "${path:=$opath}"
        ;;
      "~"*)
        username=${path%%/*}
        username=${username#"~"}
        IFS=: read _ _ _ _ _ homedir _ < <(getent passwd "$username")
        if [ "$homedir" ]; then
            if [[ $path = */* ]]; then
              path=${homedir}/${path#*/}
            else
              path=$homedir
            fi
        fi
        ;;
    esac
    resultPathElements+=( "$path" )
  done
  local result
  printf -v result '%s:' "${resultPathElements[@]}"
  printf '%s\n' "${result%:}"
}
