#!/bin/bash

if [ "$HOME/.bashrc" ]; then
echo "HOME=$HOSTNAME">>"$HOME/.bashrc"
echo "LOCAL=$(whoami)">>"$HOME/.bashrc"
gnome-terminal & disown
else
echo "Not Found!\n"
fi
