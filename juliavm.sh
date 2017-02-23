#!/usr/bin/env bash

# Setup mirror location if not already set
if [ -z "$JULIAVM_JULIA_MIRROR" ]; then
  export JULIAVM_JULIA_MIRROR="https://github.com/JuliaLang/julia/releases"
fi


juliavm_ls_remote() {
  echo "List of versions avaliable for julia language:"
}

juliavm_help() {
  echo "Command not found, commands avaliable are: "
  echo "ls-remote - list all remote versions"
  echo "ls - list all locale versions"
  echo "help - list all commands"
}

if [ "$1" == 'ls-remote' ]; then
  juliavm_ls_remote
elif [ "$1" == "help" ]; then
  juliavm_help
else 
  juliavm_help
fi
