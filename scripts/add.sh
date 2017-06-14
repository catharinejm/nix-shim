# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

function print_add_usage_and_die {
    echo
    echo "Usage: nix-shim add ( -p <package> <command>+ | <command> )"
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
            if [[ $# -lt 2 ]]; then
                print_add_usage_and_die
            fi
            add_new_command "$@"
            ;;
        --help)
            print_add_usage_and_die
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
    local new_package="$1"
    shift
    local new_commands=($@)

    if [[ "$new_package" == "nix-shim" ]]; then
        echo "Sorry, you can't add nix-shim to itself..."
        exit 1
    fi

    local plural=$(if [[ ${#new_commands} -gt 1 ]]; then echo -n s; fi)
    echo
    echo "Adding ${#new_commands} command${plural} to package $new_package:"
    echo

    for cmd in $new_commands; do
        echo "  $cmd"
        ln -nsf "$(realpath -s "$NIX_SHIM_BIN_DIR/nix-shim")" "$NIX_SHIM_BIN_DIR/$cmd"
        cmds[$cmd]=$new_package
    done
    echo

    local package_ary
    set +u
    package_ary=($(echo ${packages[$new_package]}))
    set -u
    package_ary+=($new_commands)
    packages[$new_package]="$(echo ${(uo)package_ary})"

    rewrite_cmds_sh
}
