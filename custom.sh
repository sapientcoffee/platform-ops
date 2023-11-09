#!/bin/sh
runuser user -c "touch ~/.rob"
runuser user -c "cp /sapientcoffee/settings/settings.json /home/user/.codeoss-cloudworkstations/data/Machine/"
runuser user -c "cp /sapientcoffee/settings/.p10k.zsh /home/user/"

runuser user -c "sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && echo "installed oh-my-zsh""
runuser user -c "git clone https://github.com/romkatv/powerlevel10k.git /home/user/.oh-my-zsh/custom/themes/powerlevel10k"

runuser user -c "cp /sapientcoffee/settings/zshrc ~/.zshrc"
runuser user -c "cp /sapientcoffee/settings/zshrc ~/.zshrc-cp"
runuser user -c "echo "exec zsh" >> /home/user/.bashrc"
