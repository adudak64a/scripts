#/bin/bash

sudo apt update -y
sudo apt install curl git -y

bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"


sed -i 's/plugins=(/plugins=(ansible pyenv battery/' ~/.bashrc
sed -i 's/OSH_THEME=\"font\"/OSH_THEME=\"powerline\"/' ~/.bashrc

source ~/.bashrc
