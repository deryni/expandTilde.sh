#!/bin/bash

if [ "$1" = "-v" ]; then
    v=$1
    shift
fi

. ./tildeExpand.sh

strexp() {
    local v
    v=$(printf %q "$1")
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

# shellcheck disable=SC2088
{
name1="~/Documents/over  enthusiastic"
name2="~crl/Documents/double  spaced"
name3="/work/whiffle/two  spaces  are  better  than one"
name4="~nobody/Documents/double  spaced"

ts "~+"         ~+
ts "~+/plus"    ~+/plus
ts "~-"         ~-
ts "~-/minus"   ~-/minus

cd /tmp; cd - >/dev/null

ts "$name1" "$(strexp "$name1")"
ts "$name2" "$(strexp "$name2")"
ts "$name3" "$(strexp "$name3")"
ts "$name4" "$(strexp "$name4")"
ts "~"          "$HOME"
ts "~/"         "$HOME/"
ts "~crl"       ~crl
ts "~crl/"      ~crl/
ts "~nobody"    ~nobody
ts "~nobody/"   ~nobody/
ts "~+"         ~+
ts "~+/plus"    ~+/plus
ts "~-"         ~-
ts "~-/minus"   ~-/minus

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

ts  '~1'   ~1
ts '~+1'  ~+1
ts '~-1'  ~-1
ts  '~1+'  ~1+
ts '~+1+' ~+1+
ts '~-1+' ~-1+
ts  '~2'   ~2
ts '~+2'  ~+2
ts '~-2'  ~-2
ts  '~2+'  ~2+
ts '~+2+' ~+2+
ts '~-2+' ~-2+
ts  '~8'   ~8
ts '~+8'  ~+8
ts '~-8'  ~-8
ts  '~8+'  ~8+
ts '~+8+' ~+8+
ts '~-8+' ~-8+
}

(unset -v HOME; ta '~' ~)
(unset -v HOME; ta '~/foo' ~/foo)
