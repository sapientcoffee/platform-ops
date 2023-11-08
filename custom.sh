#!/bin/sh
runuser user -c "export TEST_VAR=rob"
runuser user -c -l "cp /sapientcoffee/settings/settings.json $HOME/.codeoss-cloudworkstations/data/Machine/"


runuser user -c -l "git clone https://github.com/romkatv/powerlevel10k.git /home/user/.oh-my-zsh/custom/themes/powerlevel10k"

runuser user -c -l "cp /sapientcoffee/settings/zshrc ~/.zshrc"
runuser user -c -l "echo "exec zsh" >> ~/.bashrc"

# echo "hello world"

