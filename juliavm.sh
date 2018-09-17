#!/bin/bash

{ # this ensures the entire script is downloaded #

# Setup mirror location if not already set
export JULIAVM_JULIA_REPO="https://github.com/JuliaLang/julia"
export JULIAVM_JULIA_AWS="https://julialang-s3.julialang.org/bin/linux/"
export JULIAVM_WORK_DIR
JULIAVM_WORK_DIR=$( cd "$( dirname "$0" )" && pwd )

juliavm_echo() {
  command printf %s\\n "$*" 2>/dev/null || {
    juliavm_echo() {
      # shellcheck disable=SC1001
      \printf %s\\n "$*" # on zsh, `command printf` sometimes fails
    }
    juliavm_echo "$@"
  }
}

juliavm_ls_remote() {
  juliavm_echo "Versions available for julia language:"
  command git ls-remote -t $JULIAVM_JULIA_REPO | cut -d '/' -f 3 | cut -c 1 --complement |cut -d '^' -f 1
}

juliavm_install(){
  file=$(juliavm_get_file_name "$1" "$2")
  url=$(juliavm_get_download_url "$1" "$2")

  dists_dir=$(juliavm_get_dist_dir "$1" "$2")

  if [ -d "$dists_dir" ]; then
    juliavm_echo $dists_dir' already exist'
  else
    juliavm_echo 'Creating directories ...'
    command mkdir "$dists_dir"
    command cd "$dists_dir"
    juliavm_echo 'Downlowding files ...'
    command curl -O "$url"
    command cd "$JULIAVM_WORK_DIR"
    juliavm_echo 'Unzip files ...'
    command tar -xvzf "$dists_dir"/"$file".tar.gz -C "$dists_dir" --strip-components=1
    juliavm_echo 'Cleaning ...'
    command rm "$dists_dir"/"$file".tar.gz
  fi
  juliavm_echo "Julia "$1" installed!"
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
  juliavm_echo "You're using Julia $1$2"
  juliavm_echo "alias julia='$EXEC_PATH'" >> ~/.bashrc && exec bash
}

juliavm_ls(){
  DISTS_DIR="$JULIAVM_WORK_DIR/dists/"
  command ls -1 $DISTS_DIR
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
    juliavm_echo "Version isn't available, all version ready for use are: "
    juliavm_ls
    return 1
  fi
}

juliavm_version_is_available_remote(){
  file=$(juliavm_get_file_name "$1" "$2")
  url=$(juliavm_get_download_url "$1" "$2")
  if eval "curl --output /dev/null --silent --head --fail \"$url\""; then
    return 0
  else
    juliavm_echo "$url isn't available"
    juliavm_echo "You can list all available versions with ls-remote"
    return 1
  fi
}


juliavm_get_file_name(){
  if [[ "$2" == '-x86' ]]; then
    file='julia-'$1'-linux-i686'
    juliavm_echo $file
  elif [[ "$2" == '-x64' ]]; then
    file='julia-'$1'-linux-x86_64'
    juliavm_echo $file
  else
    file='julia-'$1'-linux-x86_64'
    juliavm_echo $file
  fi
}

juliavm_get_download_url(){
  file=$(juliavm_get_file_name $1 $2)
  major=${1:0:3}'/'

  if [[ "$2" == '-x86' ]]; then
    arch='x86/'
    url=$JULIAVM_JULIA_AWS$arch$major$file'.tar.gz'
    juliavm_echo $url
  elif [[ "$2" == '-x64' ]]; then
    arch='x64/'
    url=$JULIAVM_JULIA_AWS$arch$major$file'.tar.gz'
    juliavm_echo $url
  else
    arch='x64/'
    url=$JULIAVM_JULIA_AWS$arch$major$file'.tar.gz'
    juliavm_echo $url
  fi
}

juliavm_get_dist_dir(){
  if [[ "$2" == '-x86' ]]; then
    dist_dir=$JULIAVM_WORK_DIR'/dists/'$1$2
    juliavm_echo $dist_dir
  elif [[ "$2" == '-x64' ]]; then
    dist_dir=$JULIAVM_WORK_DIR'/dists/'$1
    juliavm_echo $dist_dir
  else
    dist_dir=$JULIAVM_WORK_DIR'/dists/'$1
    juliavm_echo $dist_dir
  fi
}


juliavm_update(){
  command cd "$JULIAVM_WORK_DIR && git pull origin master"
  command mv "$JULIAVM_WORK_DIR/juliavm.sh" "$DIR/juliavm"
}


juliavm_help() {
  juliavm_echo "  install x.y.z     install x.y.x version [ARCHITECTURE]"
  juliavm_echo "  use x.y.z         use x.y.x version [ARCHITECTURE]"
  juliavm_echo "  ls-remote         list all remote versions"
  juliavm_echo "  ls                list all locale versions"
  juliavm_echo "  update            update juliavm with latest resources"
  juliavm_echo "  uninstall         uninstall juliavm and all julia versions downloaded inside juliavm"
  juliavm_echo "      --hard        uninstall all Julia packages, if isn't passed with uninstall command. soft uninstall will be used"
  juliavm_echo " "
  juliavm_echo "  help              list all commands"
  juliavm_echo " "
  juliavm_echo " ARCHITECTURE options (if you don't pass unix 64 bits will be used):"
  juliavm_echo "  -x64    unix 64 bits"
  juliavm_echo "  -x86    unix 32 bits"
}

juliavm_uninstall(){
  echo 'Uninstalling ...'
  if  [[ "$1" == '--hard' ]]; then
    juliavm_echo 'Deleting all Julia packages ...'
    juliavm_uninstall_packages
  else
    juliavm_echo 'Julia packages will be kept ...'
  fi

  DIR=$( cd "$( dirname "$0" )" && pwd )
  sed -i /'alias julia='/d  ~/.bashrc
  sed -i /'alias juliavm='/d  ~/.bashrc
  command rm -r ~/.juliavm
  command unset JULIAVM_JULIA_REPO
  command unset JULIAVM_JULIA_AWS
  command unset JULIAVM_WORK_DIR
}

juliavm_uninstall_packages(){
  command rm -rf ~/.julia
}


if [[ "$1" == 'ls-remote' ]]; then
  juliavm_ls_remote
elif [[ "$1" == 'install' ]]; then
  if  juliavm_version_is_available_remote "$2" "$3"; then
    juliavm_install "$2" "$3"
  fi
elif [[ "$1" == 'ls' ]]; then
  juliavm_ls "$2"
elif [[ "$1" == 'use' ]]; then
  if  juliavm_version_is_available_locale "$2" "$3"; then
    juliavm_use "$2" "$3"
  fi
elif [[ "$1" == 'update' ]]; then
  juliavm_update
elif [[ "$1" == 'uninstall' ]]; then
  juliavm_uninstall $2
elif [[ "$1" == *"help"* ]]; then
  juliavm_echo "Commands available are: "
  juliavm_help
else
  juliavm_echo "Command not found, commands available are: "
  juliavm_help
fi

}
