#!/bin/bash

# Only execute if this script is called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script should not be run directly. Please run xml_formatter.sh instead."
    exit 1
fi

check_commands() {
    for cmd in "$@"; do
        echo "Checking $cmd..."
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: $cmd is not installed. Please install it and try again."
            exit 1
        fi
    done
}
