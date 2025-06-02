# pipreqs Usage Guide

## Quick Start

Generate a requirements.txt file for your Python project:

```bash
pipreqs /path/to/your/project
```

## Common Use Cases

### 1. Basic Usage

```bash
# Generate requirements.txt in current directory
pipreqs .

# Generate for a specific project
pipreqs ~/my-python-project

# Force overwrite existing requirements.txt
pipreqs --force /path/to/project
```

### 2. Output Options

```bash
# Print to console instead of file
pipreqs --print /path/to/project

# Save to custom filename
pipreqs --savepath requirements-dev.txt /path/to/project

# Generate with specific encoding
pipreqs --encoding utf-8 /path/to/project
```

### 3. Version Pinning Modes

```bash
# Compatible version (default): Flask~=1.1.2
pipreqs --mode compat /path/to/project

# Minimum version: Flask>=1.1.2
pipreqs --mode gt /path/to/project

# No version pinning: Flask
pipreqs --mode no-pin /path/to/project
```

### 4. Advanced Features

```bash
# Scan Jupyter notebooks for imports
pipreqs --scan-notebooks /path/to/project

# Ignore specific directories
pipreqs --ignore tests,docs,build /path/to/project

# Use only local package information (faster, but may be less accurate)
pipreqs --use-local /path/to/project

# Ignore errors while scanning files
pipreqs --ignore-errors /path/to/project

# Don't follow symbolic links
pipreqs --no-follow-links /path/to/project
```

### 5. Requirements Management

```bash
# Compare existing requirements.txt with actual imports
pipreqs --diff requirements.txt /path/to/project

# Clean up requirements.txt (remove unused packages)
pipreqs --clean requirements.txt /path/to/project
```

### 6. Network Options

```bash
# Use custom PyPI server
pipreqs --pypi-server https://pypi.company.com /path/to/project

# Use proxy
pipreqs --proxy http://proxy.company.com:8080 /path/to/project

# Or set environment variables
export HTTP_PROXY="http://proxy.company.com:8080"
export HTTPS_PROXY="https://proxy.company.com:8443"
pipreqs /path/to/project
```

### 7. Debugging

```bash
# Enable debug output
pipreqs --debug /path/to/project
```

## Examples

### Example 1: New Project Setup

```bash
# Create a new project
mkdir my-new-project
cd my-new-project

# Write some Python code
echo "import requests
import pandas as pd
from flask import Flask" > app.py

# Generate requirements.txt
pipreqs .

# Result in requirements.txt:
# Flask==2.3.2
# pandas==2.0.3
# requests==2.31.0
```

### Example 2: CI/CD Pipeline

```bash
# In your CI/CD script
pipreqs --force --mode compat --encoding utf-8 .

# Verify the requirements
pipreqs --diff requirements.txt .
```

### Example 3: Monorepo with Multiple Projects

```bash
# Generate requirements for specific subdirectory
pipreqs --savepath backend/requirements.txt backend/
pipreqs --savepath frontend/requirements.txt frontend/
pipreqs --savepath ml/requirements.txt ml/
```

### Example 4: Jupyter Project

```bash
# Project with Jupyter notebooks
pipreqs --scan-notebooks --force ~/jupyter-project
```

## Tips and Best Practices

1. **Regular Updates**: Run pipreqs periodically to keep requirements.txt up to date
2. **Version Control**: Always commit requirements.txt to version control
3. **CI Integration**: Use pipreqs in CI to verify requirements match imports
4. **Clean Unused**: Use `--clean` flag to remove packages no longer imported
5. **Ignore Directories**: Exclude test, docs, and example directories to avoid unnecessary dependencies

## Common Issues and Solutions

### Issue: "Import not found locally"

This warning appears when pipreqs queries PyPI for package information. It's normal behavior and helps ensure accurate package names and versions.

### Issue: Missing imports

Some imports might be dynamic or conditional. You can:
- Add them manually to requirements.txt
- Use `--use-local` to rely on installed packages
- Ensure all Python files are included in the scan

### Issue: Wrong package versions

If versions seem incorrect:
- Try without `--use-local` to query PyPI
- Use `--mode no-pin` to avoid version conflicts
- Manually adjust versions based on your needs

## Difference from pip freeze

| Feature | pipreqs | pip freeze |
|---------|---------|------------|
| Scans actual imports | ✅ | ❌ |
| Includes only used packages | ✅ | ❌ |
| Works without installing | ✅ | ❌ |
| Includes sub-dependencies | ❌ | ✅ |
| Speed | Fast | Instant |
| Accuracy | High for direct imports | Complete for installed |

Choose pipreqs when you want a minimal requirements.txt based on actual usage.
Choose pip freeze when you need to replicate an exact environment.