#!/bin/bash

{
  CURRENT_DIR=$( cd "$( dirname "$0" )" && pwd )
  INSTALL_DIR="$HOME/.juliavm"

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
    eval 'mkdir $INSTALL_DIR'
    eval 'mkdir $INSTALL_DIR/dists'
  }

  juliavm_copy_files(){
    eval 'cp $CURRENT_DIR/juliavm.sh $INSTALL_DIR/juliavm'
    echo "alias juliavm='$INSTALL_DIR/juliavm'" >> ~/.bashrc && exec bash
    eval 'cp -r $CURRENT_DIR/.git $INSTALL_DIR'
  }

  juliavm_install
}
