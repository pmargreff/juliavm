#!/bin/bash          

DIR=$( cd "$( dirname "$0" )" && pwd )
eval 'mkdir ~/.juliavm'
eval 'mkdir ~/.juliavm/dists'
eval 'cp $DIR/juliavm.sh ~/.juliavm/juliavm'
eval 'cp -r $DIR/.git ~/.juliavm/'
echo "alias juliavm='~/.juliavm/juliavm'" >> ~/.bashrc && exec bash
