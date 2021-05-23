#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# micky:x:1000:1000:Mickael Gaillard,,,:/home/micky:/bin/bash

PKGS_INSTALL=false
PKGS_LIST="exa ccze htop nano git command-not-found"

USER_NAME="micky"
USER_SHELL="bash"
USER_HOME="/home/$USER_NAME"

# Check if script is run with root.
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Make all variables.
echo -e "Check state..."
USER_PATH_SHELL=$(whereis $USER_SHELL |awk '{print $2}')

USER_CURRENT_PASSWD=$(getent passwd $USER_NAME)
if [ ! $? -eq 0 ]; then
  useradd -m $USER_NAME -s $USER_PATH_SHELL
fi
USER_CURRENT_PASSWD=$(getent passwd $USER_NAME)
USER_CURRENT_SHELL=$(echo $USER_CURRENT_PASSWD | awk 'BEGIN { FS = ":" } ; {print $7}')
USER_CURRENT_HOME=$(echo $USER_CURRENT_PASSWD | awk 'BEGIN { FS = ":" } ; {print $6}')

# Install packages.
if $PKGS_INSTALL ; then
  echo -e "install tools..."
  apt-get update >/dev/null
  apt-get -qq install $PKGS_LIST >/dev/null
fi

# Define Shell to use.
if [ "$USER_CURRENT_SHELL" != "$USER_PATH_SHELL" ]; then
  echo -e "Change Shell..."
  echo -e "\tfrom $USER_CURRENT_SHELL to $USER_PATH_SHELL"
  chsh -s $USER_PATH_SHELL $USER_NAME
fi

# Define Home to use.
if [ "$USER_CURRENT_HOME" != "$USER_HOME" ]; then
  echo -e "Change Home... "
  echo -e "\tfrom $USER_CURRENT_HOME to $USER_HOME"
fi

# Deploy config.
echo -e "Get all config/script..."
git clone -q --recurse-submodules -j8 https://github.com/Theosakamg/deploy-user.git $USER_HOME/.deploy-user >/dev/null
chown -R $USER_NAME:$USER_NAME $USER_HOME/.deploy-user

if [ -e "$USER_HOME/.bash_aliases" ] && [ ! -L "$USER_HOME/.bash_aliases" ]; then
  echo "Manual .bash_aliases removing..."
  mv "$USER_HOME/.bash_aliases" "$USER_HOME/.bash_aliases.old"
fi

if [ ! -e "$USER_HOME/.bash_aliases" ]; then
  echo -e "Deploy alias"
  ln -s $USER_HOME/.deploy-user/bash_aliases $USER_HOME/.bash_aliases
  chown $USER_NAME:$USER_NAME $USER_HOME/.bash_aliases
fi

if [ ! -e "$USER_HOME/.bashrc" ]; then
  echo -e "Deploy bashrc"
  ln -s $USER_HOME/.deploy-user/bashrc $USER_HOME/.bashrc
  chown $USER_NAME:$USER_NAME $USER_HOME/.bashrc
fi
