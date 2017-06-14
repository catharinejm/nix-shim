# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

function print_add_usage_and_die {
    echo
    echo "Usage: nix-shim add [-p <package>] <command>"
    echo
    echo "  Add a new command to run inside nix-shell."
    echo "  If the -p option is omitted, the package is assumed"
    echo "  to have the same name as the command"
    echo
    exit 1
}

function add_parse_args {
    if [[ $# -lt 1 ]]; then
        echo
        echo "ERROR: No command specified"
        print_add_usage_and_die
    fi
    case "$1" in
        -p)
            shift
            if [[ $# -ne 2 ]]; then
                print_add_usage_and_die
            fi
            add_new_command "$1" "$2"
            ;;
        *)
            if [[ $# -ne 1 ]]; then
                print_add_usage_and_die
            fi
            add_new_command "$1" "$1"
            ;;
    esac
}

function add_shim {
    add_parse_args "$@"
}

function add_new_command {
    local new_nix_package="$1"
    local new_nix_command="$2"

    echo
    echo "Adding command \`$new_nix_command' (using package \`$new_nix_package')"
    echo

    ln -nsf "$(realpath -s "$NIX_SHIM_DIR/nix-shim")" "$NIX_SHIM_DIR/shims/$new_nix_command"
    cmds[$new_nix_command]=$new_nix_package

    local package_ary
    set +u
    package_ary=($(echo ${packages[$new_nix_package]}))
    set -u
    package_ary+=($new_nix_command)
    packages[$new_nix_package]="$(echo ${(uo)package_ary})"

    rewrite_cmds_sh
}
