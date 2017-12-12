#!/bin/bash
V=$(echo ${VERSION} | cut -d'.' -f1)
if [ -z "$VERSION" ]; then
    echo "Error: VERSION not set"
    exit 1
fi
 secret_varname=$(jq -r --arg version ${V} '.products[0].projects[] | select(.version==$version) | .secret_env_name' .config/config.json)
if [ ! -z "${!secret_varname}" ]; then
    echo "${!secret_varname}"
else
    echo "Error: ${secret_varname}: not set"
    exit 1
fi