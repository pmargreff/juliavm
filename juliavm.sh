#!/bin/bash          

# Setup mirror location if not already set
if [ -z "$JULIAVM_JULIA_REPO" ]; then
  export JULIAVM_JULIA_REPO="https://github.com/JuliaLang/julia"
fi
if [ -z "$JULIAVM_JULIA_AWS" ]; then
  export JULIAVM_JULIA_AWS="https://julialang.s3.amazonaws.com/bin/linux/x64/"
fi

juliavm_ls_remote() {
  echo "List of versions available for julia language:"
  eval "git ls-remote -t $JULIAVM_JULIA_REPO | cut -d '/' -f 3 | cut -c 1 --complement |cut -d '^' -f 1"
}

juliavm_install(){
  major=${1:0:3}'/'
  file='julia-'$1'-linux-x86_64'
  url=$JULIAVM_JULIA_AWS$major$file'.tar.gz'
  JULIAVM_DISTS_DIR=$PWD'/dists/'$1
  
  if [ -d "$JULIAVM_DISTS_DIR" ]; then
    echo $JULIAVM_DISTS_DIR' already exist'
  else
    eval 'mkdir $JULIAVM_DISTS_DIR'
    eval 'wget $url -P $JULIAVM_DISTS_DIR'
    eval 'tar -xvzf $JULIAVM_DISTS_DIR/$file.tar.gz -C $JULIAVM_DISTS_DIR --strip-components=1'
    eval 'rm $JULIAVM_DISTS_DIR/$file.tar.gz'
  fi
}

juliavm_use(){
  DIR=$(juliavm_get_work_dir)
  DIR="$DIR/dists/$1/bin/julia"
  sed -i /'alias julia='/d  ~/.bashrc
  echo "You're now using Julia $1"
  echo "alias julia='$DIR'" >> ~/.bashrc && exec bash
}

juliavm_ls(){
  DIR=$(juliavm_get_work_dir)
  DIR="$DIR/dists/"
  eval 'ls -1 $DIR'
}

juliavm_version_is_available_locale(){
  DIR=$(juliavm_get_work_dir)
  DIR="$DIR/dists/$1"
  if [ -d "$DIR" ]; then
    return 0
  else 
    echo "Version isn't available, all version ready for use are: "
    juliavm_ls
    return 1
  fi
}

juliavm_version_is_available_remote(){
  major=${1:0:3}'/'
  file='julia-'$1'-linux-x86_64'
  url=$JULIAVM_JULIA_AWS$major$file'.tar.gz'
  if eval "curl --output /dev/null --silent --head --fail \"$url\""; then
    return 0
  else
    echo "$url isn't available"
    echo "You can list all available versions with ls-remote"
    return 1
  fi
}

juliavm_update(){
  DIR=$(juliavm_get_work_dir)
  eval 'cd $DIR && git pull origin master'
  eval 'mv $DIR/juliavm.sh $DIR/juliavm'
}

juliavm_get_work_dir(){
  DIR=$( cd "$( dirname "$0" )" && pwd )
  echo $DIR
}

juliavm_help() {
  echo "  install x.y.z - install x.y.x version"
  echo "  use x.y.z - use x.y.x version"
  echo "  ls-remote - list all remote versions"
  echo "  ls - list all locale versions"
  echo "  update - update juliavm with latest resources"
  echo "  help - list all commands"
}

if [[ "$1" == 'ls-remote' ]]; then
  juliavm_ls_remote
elif [[ "$1" == 'install' ]]; then
  if  juliavm_version_is_available_remote $2 ; then
    juliavm_install $2
  fi
elif [[ "$1" == 'ls' ]]; then
  juliavm_ls $2
elif [[ "$1" == 'use' ]]; then
  if  juliavm_version_is_available_locale $2 ; then
    juliavm_use $2
  fi
elif [[ "$1" == 'update' ]]; then
  juliavm_update
elif [[ "$1" == *"help"* ]]; then
  echo "Commands available are: "
  juliavm_help
else 
  echo "Command not found, commands available are: "
  juliavm_help
fi
