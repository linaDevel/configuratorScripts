#!/bin/bash

BASE_URL="https://raw.githubusercontent.com/linaDevel/usefullScripts/master"
TMPDIR=$(mktemp -d)
pushd ${TMPDIR}

wget -O common.sh "${BASE_URL}/configurator/common.sh" 2> /dev/null
source "${TMPDIR}/common.sh"

setup_requirements
setup_dev_environment
setup_zsh
setup_unity

popd
rm -rf ${TMPDIR}
