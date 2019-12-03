#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

hugo new post/$1/$(date +"%Y-%m-%d")-$2
