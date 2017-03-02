#!/bin/bash          

# Setup mirror location if not already set
if [ -z "$JULIAVM_JULIA_MIRROR" ]; then
  export JULIAVM_JULIA_MIRROR="https://github.com/JuliaLang/julia"
fi

juliavm_ls_remote() {
  echo "List of versions avaliable for julia language:"
  eval "git ls-remote -t $JULIAVM_JULIA_MIRROR | cut -d '/' -f 3 | cut -c 1 --complement |cut -d '^' -f 1"
}

juliavm_install(){
  file='julia-'$1
  url=$JULIAVM_JULIA_MIRROR'/releases/download/v'$1'/'$file'.tar.gz'
  JULIAVM_DISTS_DIR=$PWD'/dists/'$1
  
  if [ -d "$JULIAVM_DISTS_DIR" ]; then
    echo $JULIAVM_DISTS_DIR' already exist'
  else
    eval 'mkdir $JULIAVM_DISTS_DIR'
    eval 'wget $url -P $JULIAVM_DISTS_DIR'
    eval 'tar -xvzf $JULIAVM_DISTS_DIR/$file.tar.gz -C $JULIAVM_DISTS_DIR'
    eval 'rm $JULIAVM_DISTS_DIR/$file.tar.gz'
  fi
}

juliavm_version_is_available(){
  url=$JULIAVM_JULIA_MIRROR'/releases/download/v'$1'/julia-'$1'.tar.gz'
  if eval "curl --output /dev/null --silent --head --fail \"$url\""; then
    return 0
  else
    echo "Version $1 isn't available"
    echo "You can list all available versions with ls-remote parameter"
    return 1
  fi
}

juliavm_help() {
  echo "install x.y.z - install version"
  echo "ls-remote - list all remote versions"
  echo "ls - list all locale versions"
  echo "help - list all commands"
}

if [[ "$1" == 'ls-remote' ]]; then
  juliavm_ls_remote
elif [[ "$1" == "install" ]]; then
  if  juliavm_version_is_available $2 ; then
    juliavm_install $2
  fi
  
elif [[ "$1" == *"help"* ]]; then
  echo "Commands avaliable are: "
  juliavm_help
else 
  echo "Command not found, commands avaliable are: "
  juliavm_help
fi
