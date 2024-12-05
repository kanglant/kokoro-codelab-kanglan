#!/bin/bash

# Fail on any error.
set -e

# Display commands being run.
# WARNING: please only enable 'set -x' if necessary for debugging, and be very
#  careful if you handle credentials (e.g. from Keystore) with 'set -x':
#  statements like "export VAR=$(cat /tmp/keystore/credentials)" will result in
#  the credentials being printed in build logs.
#  Additionally, recursive invocation with credentials as command-line
#  parameters, will print the full command, with credentials, in the build logs.
# set -x

# Code under repo is checked out to ${KOKORO_ARTIFACTS_DIR}/github.
# The final directory name in this path is determined by the scm name specified
# in the job configuration.
#cd "${KOKORO_ARTIFACTS_DIR}/github/kokoro-codelab-kanglan"
#./build.sh
echo "$KOKORO_JOB_NAME"
function upgrade_pyenv() {
  echo "Upgrading pyenv..."
  if [[ ! -d "$PYENV_ROOT" ]]; then
    brew list pyenv &>/dev/null || echo "pyenv is not pre-installed." && exit 1
  fi
  if brew list pyenv &>/dev/null; then
    # On "ventura-slcn" VMs, pyenv is managed via Homebrew.
    echo "pyenv is installed and managed by homebrew."
    brew update && brew upgrade pyenv
  else
    echo "pyenv is not managed by homebrew. Installing it via github..."
    # TODO(kanglan): On "ventura" VMs, check the log to see if pyenv is also
    # managed by Homebrew. If not, install the latest pyenv from github.
    cp "$PYENV_ROOT" /tmp/pyenv_backup
    rm -rf "$PYENV_ROOT"
    git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
  fi
  pyenv --version
}

function install_python() {
  echo "Python setup..."
  pyenv install 3.13
  pyenv global 3.13
  PYTHON=$(pyenv which python)
  echo $PYTHON
}

function install_dependencies() {
  echo "Install dependencies..."
  cd github/jax
  "$PYTHON" -m pip install --upgrade pip
  "$PYTHON" -m pip install -r --upgrade -r ./build/requirements.in
}

upgrade_pyenv
install_python
install_dependencies
