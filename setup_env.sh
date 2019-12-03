#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

function not_installed_command {
    if hash $1 2>/dev/null; then
        echo "$1 is installed"
        # 1 = false
        return 1
    else
        echo "$1 is not installed"
        # 0 = true
        return 0
    fi
}

function not_installed_python_package {
    if pip list | grep $1 2>/dev/null; then
        echo "$1 python package is installed"
        # 1 = false
        return 1
    else
        echo "$1 python package is not installed"
        # 0 = true
        return 0
    fi
}

if not_installed_command brew ; then
    echo "Installing homebrew ..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# format: command_name=package_name
brew_packages="hugo=hugo;python=python;"
python_global_packages="Pygments;"

echo $brew_packages | while IFS='=' read -d';' command_name brew_package_name; do
    if not_installed_command $command_name ; then
        echo "Installing $brew_package_name using Homebrew ..."
        brew install $brew_package_name
    fi
done

echo $python_global_packages | while IFS=';' read python_package_name; do
    if not_installed_python_package $python_package_name ; then
        echo "Installing python package: $python_package_name using pip ..."
        pip install $python_package_name
    fi
done
