#!/bin/bash

# Only execute if this script is called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script should not be run directly. Please run xml_formatter.sh instead."
    exit 1
fi

parse_options() {
    local fix_files=false
    local indent_type="space"
    local indent_count=4
    local verbose_mode=false
    local quiet_mode=false
    local paths=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f)
                fix_files=true
                shift
            ;;
            -i)
                if [[ "$2" != "space" && "$2" != "tab" ]]; then
                    echo "Error: -i option must be followed by 'space' or 'tab'" >&2
                    exit 1
                fi
                indent_type="$2"
                shift 2
            ;;
            -s)
                if ! [[ "$2" =~ ^[0-9]+$ ]]; then
                    echo "Error: -s option must be followed by a positive integer" >&2
                    exit 1
                fi
                indent_count="$2"
                shift 2
            ;;
            -v)
                verbose_mode=true
                shift
            ;;
            -q)
                quiet_mode=true
                shift
            ;;
            # if an invalid option is provided
            -*)
                echo "Error: Unknown option $1" >&2
                exit 1
            ;;
            *)
                paths+=("$1")
                shift
            ;;
        esac
    done
    
    local XMLLINT_INDENT
    
    #use indent count only if indent type is space
    if [[ "$indent_type" == "space" ]]; then
        XMLLINT_INDENT=$(printf '%*s' "$indent_count" '')
    else
        XMLLINT_INDENT=$'\t'
    fi
    
    # Return the options and remaining arguments
    echo "$fix_files|$XMLLINT_INDENT|$verbose_mode|$quiet_mode|${paths[*]}"
}

export fix_files XMLLINT_INDENT
