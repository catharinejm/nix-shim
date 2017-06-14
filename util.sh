# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

autoload -U regexp-replace

if [[ -f cmds.sh ]]; then
    source cmds.sh
else
    typeset -A cmds
    typeset -A packages
fi

source add.sh
source rm.sh
source list.sh

function print_top_usage_and_die {
    echo
    echo "Usage: nix-shim <subcommand> ..."
    echo
    echo "Available subcommands:"
    echo "  add"
    echo "  rm"
    echo "  list"
    echo

    exit 1
}

function configure {
    case "$1" in
        add)
            shift
            add_shim "$@"
            ;;
        rm) shift
            rm_shim "$@"
            ;;
        list)
            shift
            list_shims "$@"
            ;;
        *)
            print_top_usage_and_die
            ;;
    esac
}

function cmd_exists {
    if (( ${+cmds[$1]} )); then
        return 0
    else
        return 1
    fi
}

function package_exists {
    if (( ${+packages[$1]} )); then
        return 0
    else
        return 1
    fi
}

function rewrite_cmds_sh {
    echo -n                                                 > cmds.sh
    echo "# -*- mode: sh; eval: (sh-set-shell \"zsh\") -*-" >> cmds.sh
    echo "# GENERATED FILE. DO NOT EDIT"                    >> cmds.sh
    echo                                                    >> cmds.sh

    local line
    typeset -p cmds | while read -r line; do
        echo "$line" >> cmds.sh
    done

    echo >> cmds.sh

    typeset -p packages | while read -r line; do
        echo "$line" >> cmds.sh
    done
}

function run_cmd {
    local invoked="$1"
    shift

    if ! cmd_exists $invoked; then
        echo no package mapping for \'$invoked\'
        exit 1
    fi

    local args=""
    for x in "$@"; do
        local requoted="$x"
        regexp-replace requoted \' "'\\''"
        args+="'$requoted' "
    done

    exec nix-shell -p "${cmds[$invoked]}" --run "$invoked $args"
}
