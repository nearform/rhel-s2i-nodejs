#!/bin/bash

set -ex

if [ x"${PREBUILT}" = "xT" ]; then
    echo "Installing from prebuilt binary"
    tar -zxf /src/node-v${NODE_VERSION}-linux-x64.tar.gz -C /usr/local --strip-components=1
    npm install -g npm@${NPM_VERSION} -s &>/dev/null
else
    echo "INFO: Building from source"
    tar -zxf /src/node-v${NODE_VERSION}.tar.gz -C /tmp/ --strip-components=1
    cd /tmp/
    ./configure
    make -j -l8
    # mkdir tools/remark-cli
    # mkdir tools/remark-preset-lint-node
    # make lint-md-build
    make -j4 test-only
    make install
fi

# Install yarn
npm install -g yarn -s &>/dev/null

# Fix permissions for the npm update-notifier
# Fix permissions for the npm update-notifier
if [ ! -d /opt/app-root/src/.config ] ; then
  mkdir -p /opt/app-root/src/.config
fi

chmod -R 777 /opt/app-root/src/.config

# Delete NPM things that we don't really need (like tests) from node_modules
find /usr/local/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf

# Clean up the stuff we downloaded
rm -rf /src /tmp/node-v${NODE_VERSION} ~/.npm ~/.node-gyp ~/.gnupg /usr/share/man /tmp/* /usr/local/lib/node_modules/npm/man /usr/local/lib/node_modules/npm/doc /usr/local/lib/node_modules/npm/html
