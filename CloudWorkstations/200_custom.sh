#!/usr/bin/env bash

set -e # bail out early if any command fails
set -u # fail if we hit unset variables
set -o pipefail # fail if any component of any pipe fails

runuser user -c 'mkdir -p /home/user/workspace'

echo 'cloning dotfiles with yadm'
runuser user -c 'yadm clone https://github.com/sapientcoffee/dotfiles.git'

echo 'Copy IDE settings to correct location'
runuser user -c 'mkdir -p /home/user/.codeoss-cloudworkstations/data/Machine/'
runuser user -c 'cp /sapientcoffee/settings/settings.json /home/user/.codeoss-cloudworkstations/data/Machine/'

echo 'running setup script'
runuser user -c '/sapientcoffee/scripts/setup.sh'

echo 'set zsh as default'
runuser user -c 'echo "exec zsh" >> /home/user/.bashrc'