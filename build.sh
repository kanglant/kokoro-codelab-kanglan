#!/bin/bash

# Fail on any error.
set -e
# Test
# Display commands being run.
# WARNING: please only enable 'set -x' if necessary for debugging, and be very
#  careful if you handle credentials (e.g. from Keystore) with 'set -x':
#  statements like "export VAR=$(cat /tmp/keystore/credentials)" will result in
#  the credentials being printed in build logs.
#  Additionally, recursive invocation with credentials as command-line
#  parameters, will print the full command, with credentials, in the build logs.
# set -x

# if [ "$1" == "release" ]; then
#   javac -g:none Hello.java
# else
#   javac Hello.java
# fi
# java Hello

git clone --depth 1 https://github.com/tensorflow/tensorflow.git ## shallow clone, copy only the latest revision--> save time

mkdir packages
mkdir bazelcache

docker pull tensorflow/build:latest-python3.9

docker run --name tf -w /tf/tensorflow -it -d -v "${PWD}/packages:/tf/pkg" -v "${PWD}/tensorflow:/tf/tensorflow" -v "${PWD}/bazelcache:/tf/cache" tensorflow/build:latest-python3.9 bash

docker exec tf python3 tensorflow/tools/ci_build/update_version.py --nightly

docker exec tf bazel --bazelrc=/usertools/cpu.bazelrc build --config=sigbuild_local_cache tensorflow/tools/pip_package:build_pip_package

docker exec tf ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tf/pkg --cpu --nightly_flag

docker exec tf /usertools/rename_and_verify_wheels.sh

ls -al $PWD/packages

docker stop tf

# docker kill tf
# docker rm tf
