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
    for i in $CURRENT_DIR/$module/*
    do
        filename=`basename $i`
        install_raw "$i" "$HOME/$CONFIG_DIR/$module/$filename"
    done
}

function install_vim()
{
    echo "Installing vim files..."
    install "nvim/init.vim" "$CONFIG_DIR/nvim/init.vim"
    install "nvim/site" ".local/share/nvim/site"
}

function install_zsh()
{
    echo "Installing zsh files..."
    install "zsh/zhsrc" ".zshrc"
}

function install_i3()
{
    echo "Installing i3 files..."
    install_config "i3"
}

function install_rofi()
{
    echo "Installing rofi files..."
    install_config "rofi"
}

function install_polybar()
{
    echo "Installing polybar files..."
    install_config "polybar"
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
    echo -e "\t-h: display this help message"
    echo -e "\t-f: do install files; to avoid mistake, the script default to a dry-run and this force actual installation"
    echo -e "\t-v: verbose output (show details of what the script actually does)"
    echo -e "\t<command>: what to install. This can be 'all' to install everything, or a specific thing like 'vim'"
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
        install_vim
        ;;
    zsh)
        install_zsh
        ;;
    polybar)
        install_polybar
        ;;
    rofi)
        install_rofi
        ;;
    i3)
        install_i3
        ;;
    other)
        install_other
        ;;
    all)
        install_vim
        install_zsh
        install_rofi
        install_polybar
        install_i3
        install_other
        ;;
    *)
        echo "Unknow command '$1'"
        exit 1
        ;;
esac
