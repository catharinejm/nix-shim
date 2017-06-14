# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

autoload -U regexp-replace

function script_path {
    local filename="$1"
    echo "$NIX_SHIM_SCRIPT_DIR/$filename"
}

if [[ -f "$(script_path cmds.sh)" ]]; then
    source "$(script_path cmds.sh)"
else
    typeset -A cmds
    typeset -A packages
fi

source "$(script_path add.sh)"
source "$(script_path rm.sh)"
source "$(script_path list.sh)"

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
    local cmds_sh="$(script_path cmds.sh)"

    echo -n                                                 > "$cmds_sh"
    echo "# -*- mode: sh; eval: (sh-set-shell \"zsh\") -*-" >> "$cmds_sh"
    echo "# GENERATED FILE. DO NOT EDIT"                    >> "$cmds_sh"
    echo                                                    >> "$cmds_sh"

    typeset -p cmds                                         >> "$cmds_sh"

    echo                                                    >> "$cmds_sh"

    typeset -p packages                                     >> "$cmds_sh"
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
        regexp-replace requoted \' "'\\''" || true
        args+="'$requoted' "
    done

    exec nix-shell -p "${cmds[$invoked]}" --run "$invoked $args"
}
