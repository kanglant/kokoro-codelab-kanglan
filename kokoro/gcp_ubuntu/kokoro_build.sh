#!/bin/bash

# Fail on any error.
# set -e

# Display commands being run.
# WARNING: please only enable 'set -x' if necessary for debugging, and be very
#  careful if you handle credentials (e.g. from Keystore) with 'set -x':
#  statements like "export VAR=$(cat /tmp/keystore/credentials)" will result in
#  the credentials being printed in build logs.
#  Additionally, recursive invocation with credentials as command-line
#  parameters, will print the full command, with credentials, in the build logs.
# set -x
set -exu -o history -o allexport

# Install pyenv
python --version
sudo apt install libssl-dev
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
pyenv_root=$HOME/.pyenv
export PYENV_ROOT=$pyenv_root
export PATH="$HOME/.local/bin:$PYENV_ROOT/bin:$PATH"
echo 'eval "$(pyenv init - bash)"' >> ~/.profile
pyenv install 3.10
pyenv global 3.10
python --version

# Code under repo is checked out to ${KOKORO_ARTIFACTS_DIR}/github.
# The final directory name in this path is determined by the scm name specified
# in the job configuration.
# cd "${KOKORO_ARTIFACTS_DIR}/github/kokoro-codelab-kanglan"
# ./build.sh
