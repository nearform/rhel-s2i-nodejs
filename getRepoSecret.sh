#!/bin/bash
if [ -z "$VERSION" ]; then
    echo "Error: VERSION not set"
    exit 1
fi
secret_varname=$(cat .config/config.json | jq -r --arg version ${VERSION} '.products[0].projects[] | select(.version==$version) | .secret_env_name')
if [ ! -z "${!secret_varname}" ]; then
    echo "${!secret_varname}"
else
    echo "Error: ${secret_varname}: not set"
    exit 1
fi