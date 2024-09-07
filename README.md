# XML Formatter

This project consists of a set of Bash scripts designed to format and process XML files. The primary script is `xml_formatter.sh`, which relies on several helper scripts to parse options, check the operating system, verify necessary commands, and process XML files.

## Scripts

1. **xml_formatter.sh**
2. **parse_options.sh**
3. **check_os.sh**
4. **check_commands.sh**
5. **process_xml_files.sh**

### 1. xml_formatter.sh

This is the main script that orchestrates the XML formatting process. It utilizes the other scripts to ensure a smooth operation.

### 2. parse_options.sh

This script parses the command-line options and arguments. It ensures that at least one path is provided and sets up necessary variables for further processing.

### 3. check_os.sh

This script checks the operating system and ensures the script is not run on incompatible systems like Windows.

### 4. check_commands.sh

This script verifies that required commands (`xmllint` and `diff`) are installed on the system before proceeding.

### 5. process_xml_files.sh

This script processes the XML files, either formatting them or showing differences based on the options provided.

## Usage

Run `xml_formatter.sh` with the appropriate options and paths to process XML files.

```bash
./xml_formatter.sh [OPTIONS] path1 [path2 ... pathN]
```

## Options

- `-f`: Fix the XML files instead of just showing differences.
- `-i`: Set the XML indentation (e.g., `'    '` for 4 spaces or `$'\t'` for a tab).
- `-h, --help`: Show the help message and exit.

## Example

To format XML files in the current directory with a tab indentation:

```bash
./xml_formatter.sh -i $'\t' *.xml
```

To show differences without fixing:

```bash
./xml_formatter.sh *.xml
```
