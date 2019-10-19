#!/bin/bash

{
  CURRENT_DIR=$( cd "$( dirname "$0" )" && pwd )
  INSTALL_DIR="$HOME/.juliavm"
  PATH_DIR="$HOME/.local/bin"

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
    eval 'mkdir -p $PATH_DIR'
  }

  juliavm_copy_files(){
    eval 'cp $CURRENT_DIR/juliavm.sh $PATH_DIR/juliavm'
  }

  juliavm_install
}
