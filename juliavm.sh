#!/usr/bin/env bash

# Setup mirror location if not already set
if [ -z "$JULIAVM_JULIA_MIRROR" ]; then
  export JULIAVM_JULIA_MIRROR="https://github.com/JuliaLang/julia"
fi


juliavm_ls_remote() {
  echo "List of versions avaliable for julia language:"
  eval "git ls-remote -t $JULIAVM_JULIA_MIRROR | cut -d '/' -f 3 | cut -d '^' -f 1"
}

juliavm_help() {
  echo "ls-remote - list all remote versions"
  echo "ls - list all locale versions"
  echo "help - list all commands"
}

if [[ "$1" == 'ls-remote' ]]; then
  juliavm_ls_remote
elif [[ "$1" == *"help"* ]]; then
  echo "Commands avaliable are: "
  juliavm_help
else 
  echo "Command not found, commands avaliable are: "
  juliavm_help
fi
