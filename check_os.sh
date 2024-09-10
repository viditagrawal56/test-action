#!/bin/bash

# Only execute if this script is called directly
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
    echo "This script should not be run directly. Please run xml_formatter.sh instead."
    exit 1
}

check_os() {
    case "$OSTYPE" in
    msys | cygwin | win32)
        echo "Error: This script is not compatible with Windows. Please run it in a Unix-like environment."
        exit 1
        ;;
    esac
}
