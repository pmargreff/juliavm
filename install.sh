#!/bin/bash

{
  CURRENT_DIR=$( cd "$( dirname "$0" )" && pwd )
  INSTALL_DIR="$HOME/.local/share/juliavm"
  BINDIR="$HOME/.local/bin"
  MANDIR="$HOME/.local/man/man1"

  juliavm_echo() {
    command printf %s\\n "$*" 2>/dev/null || {
      juliavm_echo() {
        # shellcheck disable=SC1001
        \printf %s\\n "$*" # on zsh, `command printf` sometimes fails
      }
      juliavm_echo "$@"
    }
  }

  juliavm_install(){
    juliavm_echo "Creating directories structure ..."
    juliavm_create_directories
    juliavm_echo "Moving files ..."
    juliavm_copy_files
    juliavm_echo "Juliavm successfully installed!!"
  }

  juliavm_create_directories(){
    eval 'mkdir -p $INSTALL_DIR/dists'
    eval 'mkdir -p $BINDIR'
    eval 'mkdir -p $MANDIR'
  }

  juliavm_copy_files(){
    eval 'cp $CURRENT_DIR/juliavm.sh $BINDIR/juliavm'
  }

  juliavm_install
}
