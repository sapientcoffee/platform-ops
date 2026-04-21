#!/usr/bin/env bash

set -e # bail out early if any command fails
set -u # fail if we hit unset variables
set -o pipefail # fail if any component of any pipe fails

wget -qO nvm_install.sh https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh && PROFILE=/dev/null bash nvm_install.sh && rm nvm_install.sh

echo "export NVM_DIR=\"\$HOME/.nvm\"
[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"" >> /home/user/.secrets