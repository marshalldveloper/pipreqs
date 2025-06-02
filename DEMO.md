# pipreqs System Package Detection Demo

This demo showcases the new system package detection features added to pipreqs.

## New Features

1. **System Package Detection**: Automatically detects which Python packages are available via apt
2. **Smart Categorization**: Groups packages by recommended installation method (apt/pipx/pip)
3. **Multiple Output Formats**: Generate different requirement file formats
4. **Reduced PyPI Queries**: Skip PyPI lookups for packages available via system package manager

## Usage Examples

### 1. Standard Requirements (Original Behavior)
```bash
pipreqs demo_project/
```

### 2. Enable System Package Detection
```bash
pipreqs demo_project/ --system-packages
```
This checks apt-cache before querying PyPI, reducing network requests.

### 3. Categorized Output
```bash
pipreqs demo_project/ --categorize --print
```
Output:
```
# System packages (install with apt)
# sudo apt install python3-numpy python3-pandas python3-flask ...
# ✓ python3-numpy (Python: numpy)
# ✗ python3-pandas (Python: pandas) 
# ...

# Developer tools (install with pipx)
# pipx install black
# pipx install mypy
# pipx install flake8

# Python packages (install with pip)
boto3
tensorflow
plotly
```

### 4. APT Requirements Format
```bash
pipreqs demo_project/ --system-packages --output-format apt
```
Generates `apt-requirements.txt` with apt installation instructions.

### 5. JSON Output
```bash
pipreqs demo_project/ --system-packages --output-format json
```
Generates detailed JSON with categorization and installation status.

## Benefits

1. **Reduced Dependencies**: Use system packages to minimize virtualenv bloat
2. **Faster Installation**: System packages are pre-compiled and optimized
3. **Better Security**: System packages receive OS security updates
4. **Smart Tool Management**: Developer tools suggested for pipx isolation
5. **Flexible Deployment**: Choose between pip, apt, or mixed approaches

## Example: Mixed Installation Strategy

For the demo project, you could:
```bash
# 1. Install system packages
sudo apt install python3-numpy python3-pandas python3-flask python3-scipy \
                 python3-matplotlib python3-sqlalchemy python3-requests

# 2. Install developer tools globally
pipx install black
pipx install mypy
pipx install flake8

# 3. Install remaining packages in virtualenv
python -m venv venv
source venv/bin/activate
pip install boto3 tensorflow plotly seaborn
```

This approach:
- Uses 7 system packages (saving ~200MB in virtualenv)
- Isolates 3 developer tools with pipx
- Only installs 4 packages via pip

## Implementation Details

- New module: `pipreqs/system_detector.py`
- Mapping file: `pipreqs/apt_mapping.json` (100+ package mappings)
- Minimal changes to existing code
- Backward compatible - all original features preserved
- Cache apt lookups for performance