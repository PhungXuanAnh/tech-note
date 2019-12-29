#!/bin/sh
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y python3-dev python3-pip python-pip virtualenv htop tree curl vim jq expect unrar \
    build-essential libssl1.0-dev libffi-dev
#-------------------------------------------------------------------------
# install docker
sudo apt-get install -y apt-transport-https ca-certificates gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
#-------------------------------------------------------------------------
# install docker compose
sudo apt-get remove docker-compose -y
sudo apt-get autoremove -y
version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sudo sh -c "curl -L https://github.com/docker/compose/releases/download/${version}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose
sudo sh -c "curl -L https://raw.githubusercontent.com/docker/compose/${version}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"
# install byobu
sudo apt-get install -y byobu
rm -rf ~/.byobu
ln -sf ~/Dropbox/Work/Other/conf.d/byobu ~/.byobu
#-------------------------------------------------------------------------
# git
sudo apt-get install -y git
#-------------------------------------------------------------------------
# install zsh
sudo apt-get install -y zsh
rm -rf ~/.zshrc
ln -sf ~/Dropbox/Work/Other/conf.d/zsh/zshrc.sh ~/.zshrc
# set zsh as default shell for root user
sudo chsh -s $(which zsh)
# set zsh as default shell for vagrant user
# echo vagrant | chsh -s $(which zsh)
chsh -s $(which zsh)
# install_oh_my_zsh
sudo curl -L http://install.ohmyz.sh | sh
git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
# choose one history tool bellow in .zshrc
# install_shell_history_interaction
# zsh history interactive selection using percol, note: only support python 2.7
# https://github.com/mooz/percol#zsh-history-search
sudo -H pip install percol
# zsh history interactive selection using hstr
# https://github.com/dvorka/hstr#hstr
sudo add-apt-repository -y ppa:ultradvorka/ppa
sudo apt-get update
sudo apt-get install -y hstr
# Create Dropbox folder
mkdir -p ~/Dropbox/Work/Other/conf.d
