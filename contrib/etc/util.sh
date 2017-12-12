#!/bin/bash
CONFIG_PATH=.config/config.json

function checkVersionIsSet() {
    V=$(echo ${VERSION} | cut -d'.' -f1)
    if [ -z "$VERSION" ]; then
        echo "Error: VERSION not set"
        exit 1
    fi
    exit 0
}

function getProjectSecret() {
    checkVersionIsSet
    secret_varname=$(jq -r --arg version ${V} '.products[0].projects[] | select(.version==$version) | .secret_env_name' ${CONFIG_PATH})
    if [ ! -z "${!secret_varname}" ]; then
        echo "${!secret_varname}"
    else
        echo "Error: ${secret_varname}: not set"
        exit 1
    fi
}

function getProjectId() {
    checkVersionIsSet
    jq -r --arg version ${V} '.products[0].projects[] | select(.version==$version) | .project_id' ${CONFIG_PATH}
}