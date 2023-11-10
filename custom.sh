#!/usr/bin/env bash

set -e # bail out early if any command fails
set -u # fail if we hit unset variables
set -o pipefail # fail if any component of any pipe fails

runuser user -c 'touch ~/.rob'
runuser user -c 'mkdir /home/user/workspace'

echo 'cleaning up previous installs'
runuser user -c 'rm -rf /home/user/.oh-my-zsh/'

echo 'install oh-my-zsh'
runuser user -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
echo 'install powerlevel10 theme'
runuser user -c 'git clone https://github.com/romkatv/powerlevel10k.git /home/user/.oh-my-zsh/custom/themes/powerlevel10k'

echo 'Copy IDE settings and terminal settings'
runuser user -c 'cp /sapientcoffee/settings/settings.json /home/user/.codeoss-cloudworkstations/data/Machine/'
runuser user -c 'cp /sapientcoffee/settings/p10k.zsh /home/user/.p10k.zsh'
runuser user -c 'cp /sapientcoffee/settings/zshrc /home/user/.zshrc'

echo 'set zsh as default'
runuser user -c 'echo "exec zsh" >> /home/user/.bashrc'

