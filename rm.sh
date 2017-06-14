# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

function print_rm_usage_and_die {
    echo
    echo "Usage: nix-shim rm ( <command> | -p <package> )"
    echo
    echo "  Remove a single command or all commands under given package"
    echo
    exit 1
}

function rm_shim {
    if [[ $# -lt 1 ]]; then
        echo
        echo "ERROR: No command specified"
        print_rm_usage_and_die
    fi

    case "$1" in
        -p)
            shift
            if [[ $# -ne 1 ]]; then
                print_rm_usage_and_die
            fi
            rm_package "$1"
            ;;
        *)
            if [[ $# -ne 1 ]]; then
                print_rm_usage_and_die
            fi
            rm_cmd "$1"
            ;;
    esac
}

function delete_symlink {
    local cmd="$1"
    rm -f "$NIX_SHIM_DIR/shims/$cmd"
}

function rm_cmd {
    local cmd=$1

    if ! cmd_exists $cmd; then
        echo "No such command: $cmd"
        exit 1
    fi

    local package=${cmds[$cmd]}

    unset "cmds[$cmd]"

    set +u
    local cmd_list=($(echo ${packages[$package]}))
    set -u
    unset "cmd_list[(ie)$cmd]"
    cmd_list=($cmd_list)

    if [[ ${#cmd_list} -eq 0 ]]; then
        unset "packages[$package]"
    else
        packages[$package]="$cmd_list"
    fi

    rewrite_cmds_sh
}

function rm_package {
    local package=$1
    if ! package_exists $package; then
        echo "No such package: $package"
        exit 1
    fi

    local cmd_list=($(echo ${packages[$package]}))
    for c in $cmd_list; do
        unset "cmds[$c]"
        rm -f "$NIX_SHIM_DIR/shims/$c"
    done
    unset "packages[$package]"

    rewrite_cmds_sh
}
