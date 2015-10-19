#!/bin/bash

if [ "$1" = "-v" ]; then
    v=$1
    shift
fi

. tildeExpand.sh

strexp() {
    local v=$(printf %q "$1")
    eval echo "${v/#\\~/"~"}"
}

t() {
    exp=$("$1" "$2")
    if [ "$v" ]; then
        printf \\n >&2
        printf 'Original: %s\n' "$2" >&2
        printf 'Expanded: %s\n' "$exp" >&2
        printf 'Expected: %s\n' "$3" >&2
    fi
    if [ "$3" = "$exp" ]; then
        printf 'Succeeded: '\''%s'\''\n' "$2"
    else
        printf 'Failed: '\''%s'\''\n' "$2"
    fi
}

ta() {
    t expandAssign "$@"
}

ts() {
    t expandString "$@"
}

cd /tmp; cd -

name1="~/Documents/over  enthusiastic"
name2="~crl/Documents/double  spaced"
name3="/work/whiffle/two  spaces  are  better  than one"
name4="~testuser/Documents/double  spaced"

ta "$name1" "$(strexp "$name1")"
ta "$name2" "$(strexp "$name2")"
ta "$name3" "$(strexp "$name3")"
ta "$name4" "$(strexp "$name4")"
ta "~"          "$HOME"
ta "~/"         "$HOME/"
ta "~crl"       ~crl
ta "~crl/"      ~crl/
ta "~testuser"  ~testuser
ta "~testuser/" ~testuser/
ta "~+"         ~+
ta "~+/plus"    ~+/plus
ta "~-"         ~-
ta "~-/minus"   ~-/minus

pt='~/foo:~/bar:~/baz'
ps=$(strexp "$pt")
pa=~/foo:~/bar:~/baz

ts "$pt" "$ps"
ta "$pt" "$pa"

o=$PWD
pushd / >/dev/null
pushd /tmp >/dev/null
pushd /opt >/dev/null
pushd /var >/dev/null
pushd "$o" >/dev/null

ta  '~1'  ~1
ta '~+1' ~+1
ta '~-1' ~-1
ta  '~2'  ~2
ta '~+2' ~+2
ta '~-2' ~-2
ta  '~8'  ~8
ta '~+8' ~+8
ta '~-8' ~-8
