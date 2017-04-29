#!/bin/bash

{
  CURRENT_DIR=$( cd "$( dirname "$0" )" && pwd )
  INSTALL_DIR="$HOME/.juliavm"

  juliavm_install(){
    juliavm_create_directories
    juliavm_copy_files
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
