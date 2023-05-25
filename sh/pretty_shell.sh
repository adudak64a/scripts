#!/bin/sh
# Need use Nerd font

# Example
# bash pretty_shell.sh zsh

oh_my_bash() {
    echo "Running oh_my_bash"
    sudo $PM update -y
    sudo $PM install curl git -y
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
    sed -i 's/plugins=(/plugins=(ansible pyenv battery/' ~/.bashrc
    sed -i 's/OSH_THEME=\"font\"/OSH_THEME=\"powerline\"/' ~/.bashrc
    source ~/.bashrc
}

oh_my_zsh() {
    echo "Running oh_my_zsh"
    sudo $PM update -y
    sudo $PM install zsh curl git -y
    zsh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
    sed -i 's/plugins=(.*)/plugins=(python rust pyenv git wd docker zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
    sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/' ~/.zshrc
    chsh -s /bin/zsh
    source ~/.zshrc
}

oh_my_fish() {
    echo "Running oh_my_fish"
    sudo $PM update -y
    sudo $PM install curl git fish -y
    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
    omf install neolambda flash
    chsh -s /usr/bin/fish
}
which apt >/dev/zero
if [ $? -eq 0 ]
then
    echo "apt is here"
    PM="apt"
fi
which zypper >/dev/zero
if [ $? -eq 0 ]
then
    echo "zypper is here"
    PM="zypper"
fi
which yum >/dev/zero
if [ $? -eq 0 ]
then
    echo "yum is here"
    PM="yum"
fi


if [[ $1 == "zsh" ]]
then
    oh_my_zsh
elif [[ $1 == "bash" ]]
then
    oh_my_bash
elif [[ $1 == "fish" ]]
then
    oh_my_fish
else
    echo "Bad parameter"
fi
