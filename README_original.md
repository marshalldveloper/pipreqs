# pipreqs - System-Aware Python Dependency Scanner

[![Python 3.7+](https://img.shields.io/badge/python-3.7+-blue.svg)](https://www.python.org/downloads/)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

**Modernized pipreqs with system package awareness for Ubuntu/Debian systems.**

## 🚀 What's New

This modernized version of pipreqs adds intelligent system package detection:

- **🔍 System Package Detection**: Automatically detects packages available via `apt`
- **📦 Smart Categorization**: Separates packages into `apt`, `pipx`, and `pip` categories  
- **⚡ Reduced Dependencies**: Use system packages instead of creating massive virtual environments
- **🛡️ Better Security**: System packages receive automatic security updates
- **🔧 Multiple Formats**: Generate installation scripts, JSON, or traditional requirements.txt

## Installation

```bash
# From source (recommended for latest features)
git clone https://github.com/yourusername/pipreqs.git
cd pipreqs
pip install -e .

# Or traditional pip install (original version)
pip install pipreqs
```

## Quick Start

```bash
# Traditional usage (backward compatible)
pipreqs /path/to/project

# System-aware usage (NEW!)
pipreqs /path/to/project --system-packages --categorize

# Generate apt installation commands
pipreqs /path/to/project --output-format apt

# JSON output with metadata
pipreqs /path/to/project --output-format json
```

## 🎯 System-Aware Features

### Smart Package Detection

Instead of this traditional approach:
```bash
pip install numpy pandas matplotlib flask
```

Get system-optimized recommendations:
```bash
# System packages (faster, more secure)
sudo apt install python3-numpy python3-pandas python3-matplotlib python3-flask

# CLI tools (isolated)
pipx install black flake8 mypy

# Project-specific packages
pip install custom-package your-internal-lib
```

### Multiple Output Formats

```bash
# Categorized output
pipreqs . --categorize
# Output:
# === SYSTEM PACKAGES (install via apt) ===
# sudo apt install python3-numpy python3-pandas
# 
# === CLI APPLICATIONS (install via pipx) ===  
# pipx install black
# pipx install flake8
#
# === PROJECT LIBRARIES (install via pip) ===
# pip install custom-package

# JSON format for CI/CD
pipreqs . --output-format json > requirements.json
```

## CLI Options

- `--system-packages`: Enable system package detection
- `--categorize`: Group packages by installation method
- `--output-format {requirements,apt,categorized,json}`: Choose output format
- `--print`: Print to stdout instead of file
- All original pipreqs options remain available

## Benefits

### For Developers
- **Faster setup**: System packages install instantly
- **Smaller virtualenvs**: Fewer packages to manage
- **Better isolation**: CLI tools via pipx don't interfere

### For DevOps
- **Consistent environments**: System packages are the same across deployments
- **Security**: Automatic security updates via apt
- **Docker optimization**: Smaller container images

### For System Administrators  
- **Centralized management**: System packages managed via standard tools
- **Compliance**: Use approved system packages
- **Monitoring**: Track dependencies via package manager

## Supported Systems

- **Primary**: Ubuntu 20.04+ (LTS), Debian 11+
- **Experimental**: Other apt-based distributions
- **Fallback**: All systems (disables system detection, works like original pipreqs)

## Architecture

The system detection works by:

1. **Import scanning**: Analyzes Python files for import statements
2. **Package mapping**: Maps Python packages to system package names  
3. **Availability checking**: Uses `apt-cache` to verify package availability
4. **Smart categorization**: Applies best practices for package management

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

Apache 2.0 License - see [LICENSE](LICENSE) file.

## Acknowledgments

- Original pipreqs by [@bndr](https://github.com/bndr)
- System package detection inspired by modern Python packaging best practices
- Ubuntu/Debian package mapping community

---

**Modern Python packaging made simple.** 🚀
