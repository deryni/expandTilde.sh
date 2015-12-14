#!/bin/bash

doExpand() {
  local path
  local -a resultPathElements

  for path in "$@"; do
    : "$path"
    case $path in
      "~"|"~"/*)
        path=${HOME-~}${path#"~"}
        ;;
      "~"[0-9]|"~"[+-][0-9])
        local num=${path#"~"}
        local op=${num%%[0-9]*}
        num=${num#[+-]}
        local opath=$path
        if [ "$op" = "-" ]; then
          ((num+=1))
        fi
        path=${DIRSTACK[@]: $op$num:1}
        : "${path:=$opath}"
        ;;
      "~+"*)
        path=$PWD${path#"~+"}
        ;;
      "~-"*)
        path=${OLDPWD:-"~-"}${path#"~-"}
        ;;
      "~"*)
        local username=${path%%/*}
        username=${username#"~"}
        IFS=: read -r _ _ _ _ _ homedir _ < <(getent passwd "$username")
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

expandAssign() {
  local -a pathElements
  IFS=: read -r -a pathElements <<<"$1"
  : "${pathElements[@]}"
  doExpand "${pathElements[@]}"
}

expandString() {
    doExpand "$1"
}
