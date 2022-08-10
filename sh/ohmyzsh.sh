#/bin/bash

sudo apt update -y
sudo apt install zsh curl git -y

zsh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting

sed -i 's/plugins=(.*)/plugins=(python rust pyenv git wd docker zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/' ~/.zshrc

chsh -s /bin/zsh

source ~/.zshrc
