#!/bin/bash

# Package categorization script
# Usage: ./check_packages.sh [filename]
# If no filename provided, defaults to requirements.txt

set -e

# Default file
DEFAULT_FILE="requirements.txt"
PACKAGE_FILE="${1:-$DEFAULT_FILE}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if file exists
if [[ ! -f "$PACKAGE_FILE" ]]; then
    echo -e "${RED}Error: File '$PACKAGE_FILE' not found${NC}"
    echo "Usage: $0 [filename]"
    echo "Example: $0 requirements.txt"
    exit 1
fi

echo -e "${BLUE}Analyzing packages from: $PACKAGE_FILE${NC}"
echo "========================================"

# Arrays to store categorized packages
apt_packages=()
pipx_candidates=()
venv_packages=()
system_only=()
unknown_packages=()

# Function to extract package name from requirement line
extract_package_name() {
    local line="$1"
    # Remove comments, whitespace, and version specifiers
    echo "$line" | sed 's/#.*//' | sed 's/[[:space:]]*//' | sed 's/[>=<~!].*//' | sed 's/\[.*\]//'
}

# Function to check if package is Ubuntu system component
is_system_component() {
    local pkg="$1"
    local system_components=(
        "aptdaemon" "command-not-found" "cupshelpers" "dbus-python"
        "language-selector" "python-apt" "python-debian" "systemd-python"
        "ubuntu-drivers-common" "ubuntu-pro-client" "ufw" "unattended-upgrades"
        "cloud-init" "screen-resolution-extra" "xkit" "brlapi" "louis"
        "pycairo" "pygobject" "pyxdg"
    )
    
    for comp in "${system_components[@]}"; do
        if [[ "$pkg" == "$comp"* ]]; then
            return 0
        fi
    done
    return 1
}

# Function to check apt availability
check_apt_availability() {
    local pkg="$1"
    apt search "python3-$pkg" 2>/dev/null | grep -q "^python3-$pkg"
}

# Function to check if package has CLI tools
check_cli_tools() {
    local pkg="$1"
    # Try to get package info and check for console scripts
    if command -v pip3 >/dev/null 2>&1; then
        pip3 show "$pkg" 2>/dev/null | grep -q "console_scripts\|scripts" 2>/dev/null
    else
        return 1
    fi
}

# Read and process each line
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    
    # Extract package name
    package=$(extract_package_name "$line")
    [[ -z "$package" ]] && continue
    
    echo -n "Checking $package... "
    
    # Check if it's a system component
    if is_system_component "$package"; then
        system_only+=("$package")
        echo -e "${YELLOW}System component (leave as-is)${NC}"
        continue
    fi
    
    # Check apt availability
    if check_apt_availability "$package"; then
        apt_packages+=("$package")
        echo -e "${GREEN}Available via apt${NC}"
        continue
    fi
    
    # Check if it might be a CLI application
    if check_cli_tools "$package"; then
        pipx_candidates+=("$package")
        echo -e "${BLUE}Potential pipx candidate (has CLI tools)${NC}"
        continue
    fi
    
    # Default to virtual environment
    venv_packages+=("$package")
    echo -e "${NC}Use in virtual environment${NC}"
    
done < "$PACKAGE_FILE"

echo
echo "========================================"
echo -e "${BLUE}CATEGORIZATION SUMMARY${NC}"
echo "========================================"

if [[ ${#apt_packages[@]} -gt 0 ]]; then
    echo -e "\n${GREEN}📦 SYSTEM PACKAGES (install via apt):${NC}"
    echo "sudo apt install \\"
    for pkg in "${apt_packages[@]}"; do
        echo "    python3-$pkg \\"
    done | sed '$ s/ \\$//'
fi

if [[ ${#pipx_candidates[@]} -gt 0 ]]; then
    echo -e "\n${BLUE}🔧 APPLICATIONS (consider pipx):${NC}"
    echo "# Verify these have CLI tools, then:"
    for pkg in "${pipx_candidates[@]}"; do
        echo "pipx install $pkg"
    done
fi

if [[ ${#venv_packages[@]} -gt 0 ]]; then
    echo -e "\n${NC}🐍 PROJECT LIBRARIES (use uv/pip in virtual env):${NC}"
    echo "# In your project:"
    echo "uv add \\"
    for pkg in "${venv_packages[@]}"; do
        echo "    $pkg \\"
    done | sed '$ s/ \\$//'
fi

if [[ ${#system_only[@]} -gt 0 ]]; then
    echo -e "\n${YELLOW}⚙️  SYSTEM COMPONENTS (managed by Ubuntu):${NC}"
    for pkg in "${system_only[@]}"; do
        echo "    $pkg"
    done
    echo "# These are Ubuntu system packages - don't reinstall"
fi

echo
echo "========================================"
echo -e "${BLUE}NEXT STEPS:${NC}"
echo "1. Install system packages with apt first"
echo "2. Use 'uv init project-name' for new projects"
echo "3. Use 'uv add package-name' for project dependencies"
echo "4. Use 'pipx install' for command-line applications"
echo "========================================"
