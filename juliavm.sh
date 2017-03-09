#!/bin/bash          

# Setup mirror location if not already set
if [ -z "$JULIAVM_JULIA_REPO" ]; then
  export JULIAVM_JULIA_REPO="https://github.com/JuliaLang/julia"
fi
if [ -z "$JULIAVM_JULIA_AWS" ]; then
  export JULIAVM_JULIA_AWS="https://julialang.s3.amazonaws.com/bin/linux/"
fi
if [ -z "$JULIAVM_WORK_DIR" ]; then
  export JULIAVM_WORK_DIR=$( cd "$( dirname "$0" )" && pwd )
fi


juliavm_ls_remote() {
  echo "List of versions available for julia language:"
  eval "git ls-remote -t $JULIAVM_JULIA_REPO | cut -d '/' -f 3 | cut -c 1 --complement |cut -d '^' -f 1"
}

juliavm_install(){
  file=$(juliavm_get_file_name $1 $2)
  url=$(juliavm_get_download_url $1 $2)
  
  dists_dir=$(juliavm_get_dist_dir $1 $2)
  
  if [ -d "$dists_dir" ]; then
    echo $dists_dir' already exist'
  else
    eval 'mkdir $dists_dir'
    eval 'wget $url -P $dists_dir'
    eval 'tar -xvzf $dists_dir/$file.tar.gz -C $dists_dir --strip-components=1'
    eval 'rm $dists_dir/$file.tar.gz'
  fi
  juliavm_use $1
}

juliavm_use(){
  if [[ "$2" == '-x86' ]]; then
    EXEC_PATH="$JULIAVM_WORK_DIR/dists/$1$2/bin/julia"
  elif [[ "$2" == '-64' ]]; then
    EXEC_PATH="$JULIAVM_WORK_DIR/dists/$1/bin/julia"
  else
    EXEC_PATH="$JULIAVM_WORK_DIR/dists/$1/bin/julia"
  fi
  sed -i /'alias julia='/d  ~/.bashrc
  echo "You're now using Julia $1$2"
  echo "alias julia='$EXEC_PATH'" >> ~/.bashrc && exec bash
}

juliavm_ls(){
  DISTS_DIR="$JULIAVM_WORK_DIR/dists/"
  eval 'ls -1 $DISTS_DIR'
}

juliavm_version_is_available_locale(){
  if [[ "$2" == '-x86' ]]; then
    VERSION_DIR="$JULIAVM_WORK_DIR/dists/$1$2"
  elif [[ "$2" == '-x64' ]]; then
    VERSION_DIR="$JULIAVM_WORK_DIR/dists/$1"
  else
    VERSION_DIR="$JULIAVM_WORK_DIR/dists/$1"
  fi
  
  if [ -d "$VERSION_DIR" ]; then
    return 0
  else 
    echo "Version isn't available, all version ready for use are: "
    juliavm_ls
    return 1
  fi
}

juliavm_version_is_available_remote(){
  file=$(juliavm_get_file_name $1 $2)
  url=$(juliavm_get_download_url $1 $2)
  if eval "curl --output /dev/null --silent --head --fail \"$url\""; then
    return 0
  else
    echo "$url isn't available"
    echo "You can list all available versions with ls-remote"
    return 1
  fi
}


juliavm_get_file_name(){
  if [[ "$2" == '-x86' ]]; then
    file='julia-'$1'-linux-i686'
    echo $file
  elif [[ "$2" == '-x64' ]]; then
    file='julia-'$1'-linux-x86_64'
    echo $file
  else
    file='julia-'$1'-linux-x86_64'
    echo $file
  fi
}

juliavm_get_download_url(){
  file=$(juliavm_get_file_name $1 $2)
  major=${1:0:3}'/'
  
  if [[ "$2" == '-x86' ]]; then
    arch='x86/'
    url=$JULIAVM_JULIA_AWS$arch$major$file'.tar.gz'
    echo $url
  elif [[ "$2" == '-x64' ]]; then
    arch='x64/'
    url=$JULIAVM_JULIA_AWS$arch$major$file'.tar.gz'
    echo $url
  else
    arch='x64/'
    url=$JULIAVM_JULIA_AWS$arch$major$file'.tar.gz'
    echo $url
  fi
}

juliavm_get_dist_dir(){
  if [[ "$2" == '-x86' ]]; then
    dist_dir=$JULIAVM_WORK_DIR'/dists/'$1$2
    echo $dist_dir
  elif [[ "$2" == '-x64' ]]; then
    dist_dir=$JULIAVM_WORK_DIR'/dists/'$1
    echo $dist_dir
  else
    dist_dir=$JULIAVM_WORK_DIR'/dists/'$1
    echo $dist_dir
  fi
}


juliavm_update(){
  eval 'cd $JULIAVM_WORK_DIR && git pull origin master'
  eval 'mv $JULIAVM_WORK_DIR/juliavm.sh $DIR/juliavm'
}


juliavm_help() {
  echo "  install x.y.z     install x.y.x version [ARCHITECTURE]"
  echo "  use x.y.z         use x.y.x version [ARCHITECTURE]"
  echo "  ls-remote         list all remote versions"
  echo "  ls                list all locale versions"
  echo "  update            update juliavm with latest resources"
  echo "  uninstall         uninstall juliavm and all julia versions downloaded inside juliavm"
  echo "  help              list all commands"
  echo " "
  echo "ARCHITECTURE options (if you don't pass unix 64 bits will be assumed):"
  echo "  -x64    unix 64 bits"
  echo "  -x86    unix 32 bits"
}

juliavm_uninstall(){
  DIR=$( cd "$( dirname "$0" )" && pwd )
  sed -i /'alias julia='/d  ~/.bashrc
  sed -i /'alias juliavm='/d  ~/.bashrc
  eval "rm -r ~/.juliavm"  
}

if [[ "$1" == 'ls-remote' ]]; then
  juliavm_ls_remote
elif [[ "$1" == 'install' ]]; then
  if  juliavm_version_is_available_remote $2 $3; then
    juliavm_install $2 $3
  fi
elif [[ "$1" == 'ls' ]]; then
  juliavm_ls $2
elif [[ "$1" == 'use' ]]; then
  if  juliavm_version_is_available_locale $2 $3; then
    juliavm_use $2 $3
  fi
elif [[ "$1" == 'update' ]]; then
  juliavm_update
elif [[ "$1" == 'uninstall' ]]; then
  juliavm_uninstall
elif [[ "$1" == *"help"* ]]; then
  echo "Commands available are: "
  juliavm_help
else 
  echo "Command not found, commands available are: "
  juliavm_help
fi
