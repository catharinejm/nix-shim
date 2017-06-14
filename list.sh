# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

function print_list_usage_and_die {
    echo "Usage: nix-shim list"
    echo
    echo "  List all available commands"
    echo
    exit 1
}

function list_shims {
    if [[ $# -gt 0 ]]; then
        echo
        echo "Unexpected parameters: $@"
        echo
        print_list_usage_and_die
    fi

    echo
    echo "Available commands:"
    echo
    for p in ${(k)packages}; do
        echo "package $p:"
        for c in $(echo ${packages[$p]}); do
            echo "  $c"
        done
        echo
    done
}
