# devkit - bash side. Sourced from ~/.bashrc.
# Wraps devctl so the commands that produce a directory can cd the shell.

: "${DEV_HOME:=$HOME/Dev}"
export DEV_HOME

case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

dev() {
    local target arg
    # -h anywhere means help: never try to cd into a usage message.
    for arg in "$@"; do
        case "$arg" in
            -h|--help) devctl "$@"; return ;;
        esac
    done
    case "${1:-}" in
        "")
            cd "$DEV_HOME" || return 1
            # historical behaviour: drop into fish from bash. set DEV_BASH_FISH=0 to disable.
            if [ "${DEV_BASH_FISH:-1}" = 1 ] && command -v fish >/dev/null 2>&1; then
                exec fish
            fi
            ;;
        cd)
            shift
            target="$(devctl path "$@")" || return 1
            cd "$target" || return 1
            ;;
        clone|get|new|init)
            target="$(devctl "$@" | tail -n 1)" || return 1
            [ -d "$target" ] && cd "$target"
            ;;
        *)
            devctl "$@"
            ;;
    esac
}

cdd() {
    if [ $# -eq 0 ]; then
        cd "$DEV_HOME"
    else
        dev cd "$@"
    fi
}

_dev_complete() {
    local cur prev cmds
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cmds="cd clone get new init list status sync fetch each browse open mine manifest restore doctor meta site pages path root help"
    [ "$COMP_CWORD" -gt 1 ] && cmds="$cmds -h"
    if [ "$COMP_CWORD" -eq 1 ]; then
        COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
    else
        case "$prev" in
            cd|browse|open|path) COMPREPLY=( $(compgen -W "$(devctl list 2>/dev/null)" -- "$cur") ) ;;
            mine) COMPREPLY=( $(compgen -W "github gitlab" -- "$cur") ) ;;
            site|pages) COMPREPLY=( $(compgen -W "--out --refresh --local --open --serve" -- "$cur") ) ;;
            meta) COMPREPLY=( $(compgen -W "--out --refresh --local" -- "$cur") ) ;;
        esac
    fi
}
complete -F _dev_complete dev
