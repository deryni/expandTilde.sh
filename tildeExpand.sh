#!/bin/bash

tildeuser() {
    local username=${1%%/*}
    IFS=: read -r _ _ _ _ _ homedir _ < <(getent passwd -- "${username:1}")
    path=${homedir:-${1%%/*}}${1#$username}
}

tildecase() {
    case $1 in
        "~"|"~"/*)
            path=${HOME-~}${1:1}
            ;;
        "~"[0-9]*|"~"[+-][0-9]*)
            local num=${1:1}
            if [[ $num -eq $num ]] 2>/dev/null; then
                if [ "${num:0:1}" = "-" ]; then
                    ((num-=1))
                fi
                local opath=$1
                path=${DIRSTACK[@]:$num:1}
                # Handle the "special" case of ${DIRSTACK[0]} using unexpanded ~.
                if [ "${path:0:1}" = "~" ]; then
                    tildecase "$path"
                fi
                : "${path:=$opath}"
            else
                tildeuser "$1"
            fi
            ;;
        "~+"*)
            path=$PWD${1:2}
            ;;
        "~-"*)
            path=${OLDPWD:-${1:0:2}}${1:2}
            ;;
        "~"*)
            tildeuser "$1"
            ;;
    esac
}

doExpand() {
    local path
    local -a resultPathElements

    for path in "$@"; do
        tildecase "$path"
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
