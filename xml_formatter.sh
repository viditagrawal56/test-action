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
    local current=$1 total=$2 width=20
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))

    printf "\r[%s%s] %d%% (%d/%d)" \
        "$(printf '.%.0s' $(seq 1 $completed))" \
        "$(printf '.%.0s' $(seq 1 $remaining))" \
        "$percentage" "$current" "$total"
}

process_files() {
    local fix_files=$1 XMLLINT_INDENT=$2 verbose_mode=$3 quiet_mode=$4
    shift 4
    local paths=("$@")

    local total_files=0 processed_files=0
    local xml_files=()

    # Use mapfile to read find output directly into an array
    mapfile -d '' xml_files < <(
        for path in "${paths[@]}"; do
            if [[ -f "$path" && "$path" == *.xml ]]; then
                echo "$path"
            elif [[ -d "$path" ]]; then
                find "$path" -name "*.xml" -print0
            fi
        done
    )

    total_files=${#xml_files[@]}

    for file in "${xml_files[@]}"; do
        ((processed_files++))
        [[ "$quiet_mode" = false && "$verbose_mode" = false ]] &&
            update_progress "$processed_files" "$total_files"
        process_xml_file "$file" "$fix_files" "$XMLLINT_INDENT" "$verbose_mode" "$quiet_mode"
    done

    [[ "$quiet_mode" = false ]] && echo -e "\nProcessed $processed_files XML files."
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

    IFS='|' read -ra options <<<"$options_output"
    local fix_files=${options[0]}
    local XMLLINT_INDENT=${options[1]}
    local verbose_mode=${options[2]}
    local quiet_mode=${options[3]}
    local paths=("${options[@]:4}")

    if [[ ${#paths[@]} -eq 0 ]]; then
        usage
        exit 0
    fi

    process_files "$fix_files" "$XMLLINT_INDENT" "$verbose_mode" "$quiet_mode" "${paths[@]}"
}

main "$@"
