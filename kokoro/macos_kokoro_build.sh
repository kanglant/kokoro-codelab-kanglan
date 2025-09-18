#!/bin/bash

# A wrapper script that acts as an entry point for Kokoro jobs that test the
# JAX built artifacts. Triggered by the Louhi workflow upon completion of the
# build_artifacts jobs, it specifically executes macos tests within the Kokoro
# CI environment. Linux and Windows tests are currently handled through GitHub
# Actions. This script facilitates the execution of test scripts located in the
# ci/ folder of the JAX GitHub repository.
#
# -e: abort script if one command fails
# -u: error if undefined variable used
# -x: log all commands
# -o history: record shell history
# -o allexport: export all functions and variables to be available to subscripts
set -exu -o history -o allexport

export DEVELOPER_DIR=/Applications/Xcode_16.0.app/Contents/Developer

echo "Checking clang version"
clang --version

echo "Checking swift version"
swift --version

# echo "Creating input files..."
# mkdir -p ${KOKORO_GFILE_DIR}
# pwd -P ${KOKORO_GFILE_DIR}
# touch ${KOKORO_GFILE_DIR}/jaxlib-0.4.38.dev20241215-cp310-cp310-macosx_10_14_x86_64.whl
# ls -lR "${KOKORO_GFILE_DIR}"

export JAXCI_HERMETIC_PYTHON_VERSION=3.10

# Kokoro's MacOS VMs have pyenv pre-installed on both x86 and arm64 by default,
# and the $PYENV_ROOT is set to $HOME/.pyenv.
# Upgrade pyenv to the latest version (>=2.4.15) to support python 3.13.
function upgrade_pyenv() {
  echo "Upgrading pyenv..."
  echo "Current pyevn version: $(pyenv --version)"
  if brew list pyenv &>/dev/null; then
    # On "ventura-slcn" VMs, pyenv is managed via Homebrew.
    echo "pyenv is installed and managed by homebrew."
    brew update && brew upgrade pyenv
  else
    echo "pyenv is not managed by homebrew. Installing it via github..."
    # On "ventura" VMs, pyenv is not managed by Homebrew. Install the latest
    # pyenv from github.
    pushd "$PYENV_ROOT"/plugins/python-build/../.. && git pull && popd
  fi
  echo "Upgraded pyenv version: $(pyenv --version)"
}

function install_python() {
  echo "Installing Python..."
  local python_version="$1"
  pyenv install -s "$python_version"
  pyenv global "$python_version"
  JAXCI_PYTHON=$(pyenv which python)
}

upgrade_pyenv
install_python 3.13t

# git clone https://github.com/google-ml-infra/jax-fork.git ./jax
# cd jax

# artifact="jaxlib"
# CMD="./ci/build_artifacts.sh $artifact"
# eval "$CMD"

# # Install python and other dependencies as docker is not supported on mac.
# if [[ "$JAXCI_HERMETIC_PYTHON_VERSION" == "3.13" ]]; then
#   upgrade_pyenv
# fi
# install_python "$JAXCI_HERMETIC_PYTHON_VERSION"
# echo "Install dependencies..."
# "$JAXCI_PYTHON" -m pip install --upgrade pip
# "$JAXCI_PYTHON" -m pip install --upgrade -r ./build/requirements.in

# # Remove periods from the JAXCI_HERMETIC_PYTHON_VERSION, e.g., if
# # JAXCI_HERMETIC_PYTHON_VERSION is "3.10", py_version becomes "310".
# py_version="${JAXCI_HERMETIC_PYTHON_VERSION//./}"

# # Find built artifacts with the same python version and platform
# if [[ "$KOKORO_JOB_NAME" =~ .*/macos_.* ]]; then
#   wheel_pattern="*cp${py_version}*macos*x86_64.whl"
# else
#   echo "Error: Unsupported platform: $KOKORO_JOB_NAME" && exit 1
# fi

# # Only one built artifact should be found.
# # wheel_file=$(find "$KOKORO_GFILE_DIR" -name "$wheel_pattern")
# wheel_file=$(find ./dist/ -name "$wheel_pattern")

# if [[ -z "$wheel_file" ]]; then
#   echo "Error: No wheel found matching the pattern '$wheel_pattern'" && exit 1
# fi

# # Copy the built artifact to the github/jax-fork/dist/ folder.
# # mkdir -p dist
# cp "$wheel_file" ./dist/
# ls ./dist/

# # Run tests
# # echo "Run tests..."
# # ./ci/run_pytest_cpu.sh
