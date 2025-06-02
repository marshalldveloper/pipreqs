#!/bin/bash

# Python Import Scanner - Extract all imports from Python files
# Usage: ./scan_imports.sh [directory] [output_file]

set -e

# Default values
DEFAULT_DIR="."
DEFAULT_OUTPUT="discovered_imports.txt"
SCAN_DIR="${1:-$DEFAULT_DIR}"
OUTPUT_FILE="${2:-$DEFAULT_OUTPUT}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Python Import Scanner${NC}"
echo "Scanning directory: $SCAN_DIR"
echo "Output file: $OUTPUT_FILE"
echo "========================================"

# Check if scan directory exists
if [[ ! -d "$SCAN_DIR" ]]; then
    echo -e "${RED}Error: Directory '$SCAN_DIR' not found${NC}"
    echo "Usage: $0 [directory] [output_file]"
    exit 1
fi

# Create temporary files
TEMP_IMPORTS=$(mktemp)
TEMP_RAW=$(mktemp)
trap "rm -f $TEMP_IMPORTS $TEMP_RAW" EXIT

# Find all Python files
echo "🔍 Finding Python files..."
python_files=($(find "$SCAN_DIR" -name "*.py" -type f 2>/dev/null | grep -v __pycache__ | sort))

if [[ ${#python_files[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No Python files found in '$SCAN_DIR'${NC}"
    exit 0
fi

echo "Found ${#python_files[@]} Python files"

# Extract imports from each file
echo "📦 Extracting imports..."
for file in "${python_files[@]}"; do
    echo "  Processing: $file"
    
    # Extract import statements using multiple patterns
    grep -E "^[[:space:]]*import[[:space:]]+" "$file" 2>/dev/null | \
        sed 's/^[[:space:]]*//' | \
        sed 's/[[:space:]]*#.*//' >> "$TEMP_RAW" || true
    
    grep -E "^[[:space:]]*from[[:space:]]+[^[:space:]]+[[:space:]]+import" "$file" 2>/dev/null | \
        sed 's/^[[:space:]]*//' | \
        sed 's/[[:space:]]*#.*//' >> "$TEMP_RAW" || true
done

# Process raw imports to extract package names
echo "🧹 Processing import statements..."

while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    
    # Handle different import patterns
    if [[ "$line" =~ ^import[[:space:]]+(.+)$ ]]; then
        # import package, package2 as alias, package3
        imports="${BASH_REMATCH[1]}"
        # Split by comma and process each
        IFS=',' read -ra PACKAGES <<< "$imports"
        for pkg in "${PACKAGES[@]}"; do
            # Clean up whitespace and aliases
            pkg=$(echo "$pkg" | sed 's/[[:space:]]*as[[:space:]].*//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
            [[ -n "$pkg" ]] && echo "$pkg" >> "$TEMP_IMPORTS"
        done
        
    elif [[ "$line" =~ ^from[[:space:]]+([^[:space:]]+)[[:space:]]+import ]]; then
        # from package import something
        package="${BASH_REMATCH[1]}"
        [[ -n "$package" && "$package" != "." ]] && echo "$package" >> "$TEMP_IMPORTS"
    fi
done < "$TEMP_RAW"

# Extract top-level package names (first part before dots)
echo "🔝 Extracting top-level packages..."
sed 's/\..*//' "$TEMP_IMPORTS" | sort | uniq > "$TEMP_IMPORTS.clean"

# Filter out standard library modules
echo "🚫 Filtering standard library modules..."
standard_lib_modules=(
    # Built-in modules
    "sys" "os" "re" "json" "urllib" "http" "datetime" "time" "math" "random"
    "collections" "itertools" "functools" "operator" "pathlib" "glob" "shutil"
    "subprocess" "threading" "multiprocessing" "queue" "socket" "ssl" "hashlib"
    "base64" "binascii" "struct" "array" "copy" "pickle" "shelve" "sqlite3"
    "csv" "configparser" "logging" "argparse" "getopt" "tempfile" "io" "gzip"
    "zipfile" "tarfile" "bz2" "lzma" "email" "html" "xml" "unittest" "doctest"
    "pdb" "cProfile" "profile" "timeit" "trace" "gc" "weakref" "ctypes" "platform"
    "site" "sysconfig" "types" "typing" "abc" "contextlib" "dataclasses" "enum"
    "fractions" "decimal" "statistics" "warnings" "inspect" "dis" "ast" "code"
    "codeop" "keyword" "token" "tokenize" "string" "textwrap" "unicodedata"
    "stringprep" "locale" "calendar" "zoneinfo" "asyncio" "concurrent" "selectors"
    "signal" "mmap" "readline" "rlcompleter" "pkgutil" "modulefinder" "runpy"
    "importlib" "imp" "zipimport" "fileinput" "linecache" "encodings" "codecs"
    # Python 3 specific
    "builtins" "__future__" "__main__"
    # Additional standard library modules often missed
    "traceback" "pprint" "reprlib" "dbm" "nntplib" "poplib" "imaplib" "smtplib"
    "telnetlib" "uuid" "socketserver" "xmlrpc" "urllib2" "cookielib" "httplib"
    "formatter" "getpass" "gettext" "mailcap" "mailbox" "mhlib" "mimetools"
    "mimetypes" "rfc822" "mimify" "multifile" "netrc" "shlex" "pipes" "posixfile"
    "resource" "nis" "syslog" "grp" "pwd" "spwd" "crypt" "termios" "tty" "pty"
    "fcntl" "ossaudiodev" "audioop" "imageop" "aifc" "sunau" "wave" "chunk"
    "colorsys" "imghdr" "sndhdr" "sunpath" "xdrlib" "plistlib" "macpath" "macurl2path"
)

# Create exclusion pattern
exclusion_pattern=$(printf "|^%s$" "${standard_lib_modules[@]}")
exclusion_pattern=${exclusion_pattern:1}  # Remove leading |

# Create exclusion pattern
exclusion_pattern=$(printf "|^%s$" "${standard_lib_modules[@]}")
exclusion_pattern=${exclusion_pattern:1}  # Remove leading |

# Get the directory name being scanned for self-reference detection
scan_dir_name=$(basename "$(realpath "$SCAN_DIR")")

# Filter out standard library, common local modules, and self-references
grep -vE "$exclusion_pattern" "$TEMP_IMPORTS.clean" | \
    grep -vE "^(test|tests|setup|main|app|config|settings|utils|helpers|constants|__init__|__main__)$" | \
    grep -vE "^$scan_dir_name$" | \
    grep -vE "^[A-Z][A-Z_]*$" | \
    grep -vE "^(src|lib|core|common|shared|base)$" | \
    sort | uniq > "$OUTPUT_FILE"

# Statistics
total_files=${#python_files[@]}
raw_imports=$(wc -l < "$TEMP_RAW" 2>/dev/null || echo 0)
processed_imports=$(wc -l < "$TEMP_IMPORTS" 2>/dev/null || echo 0)
unique_packages=$(wc -l < "$OUTPUT_FILE" 2>/dev/null || echo 0)

echo
echo "========================================"
echo -e "${GREEN}📊 SCAN RESULTS${NC}"
echo "========================================"
echo "Python files scanned: $total_files"
echo "Raw import statements: $raw_imports"
echo "Processed imports: $processed_imports"
echo "Unique external packages: $unique_packages"
echo
echo -e "${GREEN}📝 Discovered packages written to: $OUTPUT_FILE${NC}"

if [[ $unique_packages -gt 0 ]]; then
    echo
    echo -e "${BLUE}🔍 Preview of discovered packages:${NC}"
    head -10 "$OUTPUT_FILE" | sed 's/^/  /'
    [[ $unique_packages -gt 10 ]] && echo "  ... and $(($unique_packages - 10)) more"
    
    echo
    echo -e "${YELLOW}💡 Next steps:${NC}"
    echo "1. Review the generated file: cat $OUTPUT_FILE"
    echo "2. Run package categorizer: ./check_packages.sh $OUTPUT_FILE"
    echo "3. Install system packages with apt"
    echo "4. Add project packages with: uv add \$(cat $OUTPUT_FILE | tr '\\n' ' ')"
    
    echo
    echo -e "${GREEN}📋 Filtering applied:${NC}"
    echo "  ✅ Standard library modules excluded"
    echo "  ✅ Self-references to '$scan_dir_name' excluded"
    echo "  ✅ Common local modules excluded"
    echo "  ✅ Test/config files excluded"
else
    echo -e "${YELLOW}No external packages discovered.${NC}"
    echo "This could mean:"
    echo "  • Project only uses standard library"
    echo "  • All imports are local modules"
    echo "  • No Python files found in specified directory"
fi

echo "========================================"
