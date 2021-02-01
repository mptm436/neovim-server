#!/bin/bash

set -e

hex()
{
  openssl rand -hex 8
}

echo -e "==> [Step 1] Bootstraping container .."

COMMAND="yarn start"
HOME=/home/$USER

if [ "$PKGS" != "none" ]; then
  set +e
  /usr/bin/apt-get update
  /usr/bin/apt-get install -y $PKGS
  /usr/bin/apt-get clean
  /bin/rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
  set -e
fi

if [ "${ADDUSER}" == "true" ]; then
  sudo=""
  if [ "${SUDO}" == "true" ]; then
    sudo="-G sudo"
  fi
  if [ -z "$(getent group ${USER})" ]; then
    /usr/sbin/groupadd -g ${GID} ${USER}
  fi

  if [ -z "$(getent passwd ${USER})" ]; then
    /usr/sbin/useradd -u ${UID} -g ${GID} -G sudo -s ${SHELL} -d ${HOME} -m ${sudo} ${USER} 
    if [ "${SECRET}" == "password" ]; then
      SECRET=$(hex)
      echo "Autogenerated password for user ${USER}: ${SECRET}"
    fi
    echo "${USER}:${SECRET}" | /usr/sbin/chpasswd
    unset SECRET
  fi
fi

#for service in ${SERVICE}; do
	#COMMAND+=" -s ${service}"
#done

#if [ "$SCRIPT" != "none" ]; then
	#set +e
	#/usr/bin/curl -s -k ${SCRIPT} > /prep.sh
	#chmod +x /prep.sh
	#echo "Running ${SCRIPT} .."
	#/prep.sh
	#set -e
#fi

if [ "$CONTAINER" != "wetty" ] ; then
  echo -e "==> [Step 2] Setting up environment .."
  echo "alias ..='cd ..'" >> $HOME/.bashrc && echo "alias ...='cd ../../'" >> /home/$USER/.bashrc
  echo "alias vim='nvim'" >> $HOME/.bashrc
  echo "export LANG=en_US.UTF-8" >> $HOME/.bashrc
  echo "export EDITOR=nvim" >> $HOME/.bashrc
  echo "export PATH=$HOME/.local/bin:$PATH" >> $HOME/.bashrc
  mkdir -p /workspace && ln -s /workspace $HOME/
  mkdir -p $HOME/.config && cp -r /usr/src/app/nvim $HOME/.config/
  cp -r /usr/src/app/nvim/ranger $HOME/.config
  ln -s ./.config/* /config/

  echo -e "==> [Step 3] Setting up neovim .."
  nvim --headless +PlugInstall +qall > /dev/null 2>&1
fi

chown -R ${USER}:sudo ${HOME}
chown -R ${USER}:sudo /workspace
chown -R ${USER}:sudo /config

echo -e "==> [Step 4] Starting container .."
if [ "$@" = "wetty" ]; then
  echo "==> [INFO]  Executing: ${COMMAND}"
  exec ${COMMAND}
else
  echo "==> [INFO]  Not executing: ${COMMAND}"
  echo "==> [INFO]  Executing: ${@}"
  exec $@
fi
