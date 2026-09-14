#!/bin/sh
# hollywood defaults to one pane per widget (18 of them). That is great on a
# large terminal and unreadable on 80x24, where every widget just prints
# "Terminal size should be at least 60 columns by 24 lines". With no arguments,
# pick a pane count the terminal can actually fit; pass -s to override.
if [ "$#" -eq 0 ]; then
    size=$(stty size 2>/dev/null) || size=
    lines=${size% *}
    cols=${size#* }
    case "$lines$cols" in
        '' | *[!0-9]*) lines=24; cols=80 ;;
    esac

    max=$(ls /usr/lib/hollywood 2>/dev/null | wc -l)
    [ "$max" -ge 2 ] || max=18

    splits=$(( (cols / 45) * (lines / 14) ))
    [ "$splits" -lt 2 ] && splits=2
    [ "$splits" -gt "$max" ] && splits=$max

    set -- -s "$splits"
fi

hollywood "$@"
rc=$?

# Belt and braces for the mouse: htop and urwid apps switch the terminal into
# mouse-reporting mode, and hollywood kills its panes with `pkill -9`, so they
# never switch it back. htoprc and the speedometer patch stop them asking in
# the first place; this puts the terminal back even if something else does it.
if [ -t 1 ]; then
    printf '\033[?9l\033[?1000l\033[?1001l\033[?1002l\033[?1003l'
    printf '\033[?1005l\033[?1006l\033[?1015l\033[?1016l\033[?25h'
fi
# Our quit key runs `kill-server`, which yanks the server out from under the
# attached client and makes tmux return 1. That is a normal quit here.
[ "$rc" -eq 1 ] && rc=0
exit "$rc"
