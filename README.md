# juliavm
A Julia version manager

## Install
Clone the repo: 

`git clone https://github.com/pmargreff/juliavm`

Inside the repo provide the right permissions to install: 

`cd juliavm && chmod u+x install.sh`

Run the script for install: 

`./install.sh`


## Commands

 - `juliavm ls-remote` - list all remote versions 
 - `juliavm ls` - list all locale versions
 - `juliavm install x.y.z` - install x.y.x version
 - `juliavm use x.y.z` - use x.y.x version
 - `juliavm update` - update **juliavm** with latest resources
 - `juliavm help` - list all available commands

## Architectures

Only unix 64 bits version is supported right now, in some nearby moment in the future it will be update for 32 bits and OSx versions. 
