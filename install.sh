#!/bin/sh

CURRENT_DIR=`pwd`

VIM_INIT_DIR="$HOME/.config/nvim"
VIM_SITE_DIR="$HOME/.local/share/nvim"

VIM_SOURCE_DIR="$CURRENT_DIR/vim"

echo "Create links for vim files..."

mkdir -p $VIM_INIT_DIR
mkdir -p $VIM_SITE_DIR

ln -s -f "$VIM_SOURCE_DIR/init.vim" "$VIM_INIT_DIR/init.vim"
ln -s -f "$VIM_SOURCE_DIR/site" "$VIM_SITE_DIR/site"
