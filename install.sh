#!/bin/sh

CURRENT_DIR=`pwd`
CONFIG_DIR=".config"
VERBOSE=0

# Usage: install source dest
function install()
{
    src="$CURRENT_DIR/$1"
    dst="$HOME/$2"
    dst_dir=`dirname $dst`
    if [ ! -e $dst_dir ]; then
        [ $VERBOSE -eq 1 ] && echo "Creating directory $dst_dir"
        mkdir -p "$dst_dir"
    fi

    if [ -e $dst ]; then
        # If dst exists but is not a symlink, something is wrong, error out
        if [ ! -L $dst ]; then
            echo "$dst already exists and is not a symlink; Freaking out"
            exit 1
        else
            [ $VERBOSE -eq 1 ] && echo "Removing existing symlink $dst"
            rm $dst
        fi
    fi
    [ $VERBOSE -eq 1 ] && echo "Creating symlink $src -> $dst"
    ln -s -f "$src" "$dst"
}

function install_vim()
{
    echo "Installing vim files..."
    install "vim/init.vim" "$CONFIG_DIR/nvim/init.vim"
    install "vim/site" ".local/share/nvim/site"
}

function show_help()
{
    echo  "Usage: $0 [-h] [-v] <command>"
    echo ""
    echo -e "\t-h: display this help message"
    echo -e "\t-v: verbose output (show details of what the script actually does)"
    echo -e "\t<command>: what to install. This can be 'all' to install everything, or a specific thing like 'vim'"
}

OPTIND=1 # Used by getopts
while getopts "h?v" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    v)
        VERBOSE=1
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

if [ "$#" -ne 1 ];
then
    echo "Missing what to install"
    show_help
    exit 1
fi

case "$1" in
    vim)
        install_vim
        ;;
    all)
        install_vim
        ;;
    *)
        echo "Unknow command '$1'"
        exit 1
        ;;
esac
