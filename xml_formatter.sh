#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/parse_options.sh"
source "$DIR/check_os.sh"
source "$DIR/process_xml_files.sh"
source "$DIR/check_commands.sh"

usage() {
    cat <<EOF
Usage: xml_formatter.sh [OPTIONS] path1 [path2 ... pathN]

Options:
  -f              Fix the XML files instead of just showing differences
  -i <space|tab>  Set the indentation type (default: space)
  -s <number>     Set the number of spaces for indentation (default: 4, ignored for tabs)
  -v              Verbose mode: show detailed output with path traversal details
  -q              Quiet mode: suppress all output except errors
  -h, --help      Show this help message and exit

Examples:
  xml_formatter.sh -f -i space -s 4 ./test.xml
  xml_formatter.sh -f -i tab ./test.xml
  xml_formatter.sh -v ./test_directory
  xml_formatter.sh -q -f ./test.xml
EOF
}

update_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r[%s%s] %d%% (%d/%d)" \
    "$(printf '#%.0s' $(seq 1 $completed))" \
    "$(printf '.%.0s' $(seq 1 $remaining))" \
    "$percentage" "$current" "$total"
}


process_files() {
    local fix_files=$1
    local XMLLINT_INDENT=$2
    local verbose_mode=$3
    local quiet_mode=$4
    shift 4
    local paths=("$@")
    
    local total_files=0
    local processed_files=0
    local xml_files=()
    
    # Count total XML files and store their paths
    for path in "${paths[@]}"; do
        if [ -f "$path" ] && [[ "$path" == *.xml ]]; then
            xml_files+=("$path")
            ((total_files++))
            elif [ -d "$path" ]; then
            while IFS= read -r -d '' file; do
                xml_files+=("$file")
                ((total_files++))
            done < <(find "$path" -name "*.xml" -print0)
        fi
    done
    
    for file in "${xml_files[@]}"; do
        ((processed_files++))
        if [[ "$quiet_mode" = false && "$verbose_mode" = false ]]; then
            update_progress "$processed_files" "$total_files"
        fi
        process_xml_file "$file" "$fix_files" "$XMLLINT_INDENT" "$verbose_mode" "$quiet_mode"
    done
    
    if [ "$quiet_mode" = false ]; then
        echo -e "\nProcessed $processed_files XML files."
    fi
}

main() {
    if [ $# -eq 0 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        usage
        exit 0
    fi
    
    check_os
    
    check_commands xmllint diff
    
    local options_output
    if ! options_output=$(parse_options "$@"); then
        echo ""
        usage
        exit 1
    fi
    
    # Extract values from options_output
    local fix_files
    local XMLLINT_INDENT
    local verbose_mode
    local quiet_mode
    local paths
    
    fix_files=$(echo "$options_output" | cut -d'|' -f1)
    XMLLINT_INDENT=$(echo "$options_output" | cut -d'|' -f2)
    verbose_mode=$(echo "$options_output" | cut -d'|' -f3)
    quiet_mode=$(echo "$options_output" | cut -d'|' -f4)
    paths=$(echo "$options_output" | cut -d'|' -f5-)
    
    # If no paths are provided after parsing options, show usage
    if [ -z "$paths" ]; then
        usage
        exit 0
    fi
    
    IFS=' ' read -ra path_array <<< "$paths"
    process_files "$fix_files" "$XMLLINT_INDENT" "$verbose_mode" "$quiet_mode" "${path_array[@]}"
}

main "$@"