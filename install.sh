#!/bin/sh

CURRENT_DIR=`pwd`
CONFIG_DIR=".config"
VERBOSE=0
DRY_RUN=1

# Usage: install source dest
function install()
{
    install_raw "$CURRENT_DIR/$1" "$HOME/$2"
}

function install_raw()
{
    src="$1"
    dst="$2"
    [ $VERBOSE -eq 1 ] && echo "Installing $src to $dst"
    dst_dir=`dirname $dst`
    if [ ! -e $dst_dir ]
    then
        [ $VERBOSE -eq 1 ] && echo "Creating directory $dst_dir"
        [ $DRY_RUN -eq 0 ] && mkdir -p "$dst_dir"
    fi

    if [ -e $dst ]
    then
        # If dst exists but is not a symlink, something is wrong, error out
        if [ ! -L $dst ]
        then
            echo "$dst already exists and is not a symlink; Freaking out"
            exit 1
        else
            [ $VERBOSE -eq 1 ] && echo "Removing existing symlink $dst"
            [ $DRY_RUN -eq 0 ] && rm $dst
        fi
    fi
    [ $VERBOSE -eq 1 ] && echo "Creating symlink $src -> $dst"
    [ $DRY_RUN -eq 0 ] && ln -s -f "$src" "$dst"
}

# Usage: install_config module
# As shortcut over install for things going directly in .config
function install_config()
{
    module=$1
    install_raw "$CURRENT_DIR/$module/" "$HOME/$CONFIG_DIR/$module"
}

function install_nvim()
{
    echo "Installing neovim files..."
    install_config "nvim"
}

function install_zsh()
{
    echo "Installing zsh files..."
    install "zsh/zshrc" ".zshrc"
}

function install_other()
{
    echo "Installing other files..."
    install "wallpaper.png" ".wallpaper.png"

    for i in $CURRENT_DIR/bin/*
    do
        filename=`basename $i`
        install_raw "$i" "$HOME/.bin/$filename"
    done
}

function show_help()
{
    echo  "Usage: $0 [-h] [-v] <command>"
    echo ""
    echo "\t-h: display this help message"
    echo "\t-f: do install files; to avoid mistake, the script default to a dry-run and this force actual installation"
    echo "\t-v: verbose output (show details of what the script actually does)"
    echo "\t<command>: what to install. This can be 'all' to install everything, or a specific thing like 'vim'"
}

OPTIND=1 # Used by getopts
while getopts "h?vf" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    v)
        VERBOSE=1
        ;;
    f)
        DRY_RUN=0
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

if [ "$#" -ne 1 ]
then
    echo "Missing what to install"
    show_help
    exit 1
fi

[ $DRY_RUN -eq 1 ] && echo -ne "\n!!! Running dry-run; Use -f to really install files !!!\n\n"

case "$1" in
    vim)
        install_nvim
        ;;
    zsh)
        install_zsh
        ;;
    other)
        install_other
        ;;
    all)
        install_nvim
        install_zsh
        install_other
        ;;
    *)
        echo "Unknow command '$1'"
        exit 1
        ;;
esac
