#!/bin/bash

# Parallel Package categorization script using dpkg for real package discovery
# Usage: ./check_packages.sh [filename]

set -e

# Default file
DEFAULT_FILE="requirements.txt"
PACKAGE_FILE="${1:-$DEFAULT_FILE}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Number of parallel jobs (default to CPU cores)
JOBS=${JOBS:-$(nproc)}

# Check if file exists
if [[ ! -f "$PACKAGE_FILE" ]]; then
    echo -e "${RED}Error: File '$PACKAGE_FILE' not found${NC}"
    echo "Usage: $0 [filename]"
    echo "Set JOBS=N to control parallelism (default: $(nproc) cores)"
    exit 1
fi

echo -e "${BLUE}Analyzing packages from: $PACKAGE_FILE (using $JOBS parallel jobs)${NC}"
echo "Using dpkg/apt-cache for real-time package discovery..."

# Extract package name from requirement line
extract_package_name() {
    echo "$1" | sed 's/#.*//' | sed 's/[[:space:]]*//' | sed 's/[>=<~!].*//' | sed 's/\[.*\]//' | tr '[:upper:]' '[:lower:]'
}

# Cache available python3 packages for faster lookup
echo "🔍 Building package cache..."
PACKAGE_CACHE=$(mktemp)
trap "rm -f $PACKAGE_CACHE" EXIT

# Get all available python3 packages using apt-cache
apt-cache --no-generate pkgnames python3- 2>/dev/null | sort > "$PACKAGE_CACHE" || {
    echo "⚠️  Falling back to dpkg-query..."
    dpkg-query -l 'python3-*' 2>/dev/null | awk '/^ii/ {print $2}' | sort > "$PACKAGE_CACHE"
}

echo "Found $(wc -l < "$PACKAGE_CACHE") available python3 packages"

# Pre-defined system components (Ubuntu-specific packages to leave alone)
declare -A SYSTEM_COMPONENTS=(
    ["aptdaemon"]=1 ["command-not-found"]=1 ["cupshelpers"]=1 ["dbus-python"]=1
    ["language-selector"]=1 ["python-apt"]=1 ["python-debian"]=1 ["systemd-python"]=1
    ["ubuntu-drivers-common"]=1 ["ubuntu-pro-client"]=1 ["ufw"]=1 ["unattended-upgrades"]=1
    ["cloud-init"]=1 ["screen-resolution-extra"]=1 ["xkit"]=1 ["brlapi"]=1 ["louis"]=1
    ["pycairo"]=1 ["pygobject"]=1 ["pyxdg"]=1
)

# Known CLI applications (for pipx)
declare -A KNOWN_CLI=(
    ["black"]=1 ["flake8"]=1 ["mypy"]=1 ["pytest"]=1 ["tox"]=1 ["cookiecutter"]=1
    ["jupyter"]=1 ["ipython"]=1 ["notebook"]=1 ["jupyterlab"]=1 ["streamlit"]=1
    ["pre-commit"]=1 ["poetry"]=1 ["pipenv"]=1 ["twine"]=1 ["bandit"]=1
    ["ansible"]=1 ["awscli"]=1 ["httpie"]=1 ["youtube-dl"]=1 ["yt-dlp"]=1
    ["scons"]=1 ["inflect"]=1
)

# Package name mappings for common variations
declare -A PACKAGE_MAPPINGS=(
    ["pyjwt"]="jwt"
    ["python-dateutil"]="dateutil"
    ["pyyaml"]="yaml"
    ["beautifulsoup4"]="bs4"
    ["pillow"]="pil"
    ["attrs"]="attr"
)

# Function to check if a package is available in apt
is_available_in_apt() {
    local package="$1"
    local variations=(
        "python3-$package"
        "python3-${package//\./-}"          # dots to hyphens
        "python3-${package//_/-}"           # underscores to hyphens
        "python3-${PACKAGE_MAPPINGS[$package]:-}"  # mapped name
    )
    
    for variant in "${variations[@]}"; do
        [[ -n "$variant" ]] && grep -q "^$variant$" "$PACKAGE_CACHE" && {
            echo "$variant"
            return 0
        }
    done
    return 1
}

# Function to check a single package (for parallel execution)
check_package() {
    local package="$1"
    local temp_dir="$2"
    local cache_file="$3"
    
    # Quick system component check
    if [[ -n "${SYSTEM_COMPONENTS[$package]}" ]]; then
        echo "$package" >> "$temp_dir/system"
        return 0
    fi
    
    # Check if available in apt using the cache
    if apt_package=$(is_available_in_apt "$package"); then
        echo "$package:$apt_package" >> "$temp_dir/apt"
        return 0
    fi
    
    # Check if it's a known CLI application
    if [[ -n "${KNOWN_CLI[$package]}" ]]; then
        echo "$package" >> "$temp_dir/pipx"
        return 0
    fi
    
    # CLI heuristics for unknown packages
    if [[ "$package" =~ ^(.*-cli|.*-tool|.*cmd)$ ]] || 
       command -v "$package" >/dev/null 2>&1; then
        echo "$package" >> "$temp_dir/pipx"
    else
        echo "$package" >> "$temp_dir/venv"
    fi
}

# Read packages from file
packages=()
while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    package=$(extract_package_name "$line")
    [[ -z "$package" ]] && continue
    packages+=("$package")
done < "$PACKAGE_FILE"

echo "Processing ${#packages[@]} packages using $JOBS parallel workers..."

# Create temporary directory for results
temp_dir=$(mktemp -d)
trap "rm -rf $temp_dir" EXIT

# Initialize result files
touch "$temp_dir"/{apt,pipx,venv,system}

# Create a temporary script file for parallel execution
script_file="$temp_dir/check_script.sh"
cat > "$script_file" << 'EOF'
#!/bin/bash
source "$1"  # Source the function definitions
check_package "$2" "$3" "$4"
EOF
chmod +x "$script_file"

# Export function definitions to a file
func_file="$temp_dir/functions.sh"
cat > "$func_file" << EOF
$(declare -p SYSTEM_COMPONENTS KNOWN_CLI PACKAGE_MAPPINGS)
PACKAGE_CACHE="$PACKAGE_CACHE"
$(declare -f is_available_in_apt check_package)
EOF

# Method 1: Use GNU parallel if available
if command -v parallel >/dev/null 2>&1; then
    echo "Using GNU parallel for maximum speed..."
    printf '%s\n' "${packages[@]}" | parallel -j "$JOBS" "$script_file" "$func_file" {} "$temp_dir" "$PACKAGE_CACHE"
    
# Method 2: Use xargs with parallel processing
elif command -v xargs >/dev/null 2>&1; then
    echo "Using xargs parallel processing..."
    printf '%s\n' "${packages[@]}" | xargs -P "$JOBS" -I PKG "$script_file" "$func_file" PKG "$temp_dir" "$PACKAGE_CACHE"
    
# Method 3: Bash job control fallback
else
    echo "Using bash job control..."
    
    # Source the functions for bash job control
    source "$func_file"
    
    job_count=0
    for package in "${packages[@]}"; do
        check_package "$package" "$temp_dir" "$PACKAGE_CACHE" &
        
        ((job_count++))
        
        # Limit concurrent jobs
        if (( job_count >= JOBS )); then
            wait -n  # Wait for any job to complete
            ((job_count--))
        fi
    done
    
    # Wait for remaining jobs
    wait
fi

# Collect results and extract actual package names for apt
apt_packages=()
apt_package_names=()
while IFS=':' read -r pypi_name apt_name; do
    [[ -n "$pypi_name" && -n "$apt_name" ]] || continue
    apt_packages+=("$pypi_name")
    apt_package_names+=("$apt_name")
done < <(sort "$temp_dir/apt" 2>/dev/null | uniq || true)

pipx_candidates=($(sort "$temp_dir/pipx" 2>/dev/null | uniq || true))
venv_packages=($(sort "$temp_dir/venv" 2>/dev/null | uniq || true))
system_only=($(sort "$temp_dir/system" 2>/dev/null | uniq || true))

echo
echo "========================================"
echo -e "${BLUE}CATEGORIZATION SUMMARY${NC}"
echo "========================================"

if [[ ${#apt_package_names[@]} -gt 0 ]]; then
    echo -e "\n${GREEN}📦 SYSTEM PACKAGES (install via apt):${NC}"
    echo "sudo apt install \\"
    printf '    %s \\\n' "${apt_package_names[@]}" | sed '$ s/ \\$//'
    
    echo -e "\n${GREEN}📋 Package mappings found:${NC}"
    for i in "${!apt_packages[@]}"; do
        echo "  ${apt_packages[i]} → ${apt_package_names[i]}"
    done
fi

if [[ ${#pipx_candidates[@]} -gt 0 ]]; then
    echo -e "\n${BLUE}🔧 APPLICATIONS (pipx):${NC}"
    printf 'pipx install %s\n' "${pipx_candidates[@]}"
fi

if [[ ${#venv_packages[@]} -gt 0 ]]; then
    echo -e "\n${NC}🐍 PROJECT LIBRARIES (uv/pip in venv):${NC}"
    echo "uv add \\"
    printf '    %s \\\n' "${venv_packages[@]}" | sed '$ s/ \\$//'
fi

if [[ ${#system_only[@]} -gt 0 ]]; then
    echo -e "\n${YELLOW}⚙️  SYSTEM COMPONENTS (managed by Ubuntu):${NC}"
    printf '    %s\n' "${system_only[@]}"
    echo "# Leave these as-is"
fi

echo
echo "========================================"
echo -e "${GREEN}✓ Processed ${#packages[@]} packages in parallel using live package data!${NC}"
echo "Method: $(command -v parallel >/dev/null && echo "GNU parallel" || echo "$(command -v xargs >/dev/null && echo "xargs" || echo "bash jobs")")"
echo -e "\n${BLUE}🔄 QUICK WORKFLOW:${NC}"
echo "1. Run the apt install command above"
echo "2. For projects: uv init myproject && cd myproject"
echo "3. Add project deps: uv add package1 package2"
echo "4. For CLI tools: pipx install toolname"
echo "========================================"
