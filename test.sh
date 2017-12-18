#!/bin/sh
source contrib/etc/util.sh

if isDebug; then
  echo DEBUG
else
  echo NOT_DEBUG
fi

DEBUG_BUILD=T

if isDebug; then
  echo DEBUG
else
  echo NOT_DEBUG
fi
