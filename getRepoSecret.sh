#!/bin/sh
secret_varname=$(jq -r --arg version ${VERSION} '.products[0].projects[] | select(.version==$version) | .secret_env_name' rhel-s2i-nodejs/.config/config.json)
if [ ! -z "${!secret_varname}" ]; then
    echo "${secret_varname}: found"
    echo "${!secret_varname}"
else
    echo "${secret_varname}: not set"
    exit 1
fi