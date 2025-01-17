#!/bin/bash

# Only execute if this script is called directly
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
    echo "This script should not be run directly. Please run xml_formatter.sh instead."
    exit 1
}

process_xml_file() {
    local file="$1" fix_files="$2" XMLLINT_INDENT="$3" verbose_mode="$4" quiet_mode="$5"

    if [[ "$verbose_mode" = true ]]; then
        echo -e "\nProcessing file: $file"
    fi

    if [[ "$fix_files" = true ]]; then
        format_xml_file "$file" "$XMLLINT_INDENT" "$verbose_mode"
    else
        show_xml_diff "$file" "$XMLLINT_INDENT"
    fi
}

process_xml_files_in_directory() {
    local dir="$1" fix_files="$2" XMLLINT_INDENT="$3" verbose_mode="$4" quiet_mode="$5"

    if [[ "$verbose_mode" = true ]]; then
        echo "Processing directory: $dir"
    fi

    if [[ ! -d "$dir" ]]; then
        echo "Error: Directory $dir does not exist."
        return 1
    fi

    local file
    while IFS= read -r -d '' file; do
        if [[ -d "$file" ]]; then
            process_xml_files_in_directory "$file" "$fix_files" "$XMLLINT_INDENT" "$verbose_mode" "$quiet_mode"
        elif [[ "$file" == *.xml ]]; then
            process_xml_file "$file" "$fix_files" "$XMLLINT_INDENT" "$verbose_mode" "$quiet_mode"
        elif [[ "$verbose_mode" = true ]]; then
            echo "Skipping non-XML file: $file"
        fi
    done < <(find "$dir" -print0)
}

format_xml_file() {
    local file="$1" XMLLINT_INDENT="$2" verbose_mode="$3"

    if ! XMLLINT_INDENT="$XMLLINT_INDENT" xmllint --format "$file" --output "$file"; then
        echo -e "\nError: Failed to format $file"
        return 1
    fi

    if [ "$verbose_mode" = true ]; then
        echo "Fixed formatting for file: $file"
    fi
}

show_xml_diff() {
    local file="$1" XMLLINT_INDENT="$2"

    if ! diff -B --tabsize=4 "$file" <(XMLLINT_INDENT="$XMLLINT_INDENT" xmllint --format "$file"); then
        echo -e "\nError: Failed to diff $file"
        return 1
    fi
}
