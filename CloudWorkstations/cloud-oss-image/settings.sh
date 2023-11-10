#!/bin/bash

echo "Copyng user settings"

CODEOSS_PATH="/home/user/.codeoss-cloudworkstations"
SETTINGS_PATH="$CODEOSS_PATH/data/Machine"

mkdir -p $SETTINGS_PATH

cat << EOF > $SETTINGS_PATH/settings.json
{
    "workbench.colorTheme": "Default Dark+",
    "window.menuBarVisibility": "classic",
    "files.trimFinalNewlines": true,
    "files.insertFinalNewline": true,
    "files.trimTrailingWhitespace": true,
    "files.autoSave": "on"
}
EOF

chown -R user:user $CODEOSS_PATH
chmod -R 755 $CODEOSS_PATH



# {
#     "editor.fontFamily": "'Droid Sans Mono', 'monospace', monospace",
#     "editor.fontWeight": "normal",
#     "workbench.colorTheme": "Code OSS Dark"
# }
