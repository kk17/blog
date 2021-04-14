#!/usr/bin/env bash
set -euox pipefail
IFS=$'\n\t'

source ./hugo.sh
hugo server -D


