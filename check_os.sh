#!/bin/bash

# Only execute if this script is called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script should not be run directly. Please run xml_formatter.sh instead."
    exit 1
fi

check_os() {
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "Error: This script is not compatible with Windows. Please run it in a Unix-like environment."
        exit 1
    fi
}