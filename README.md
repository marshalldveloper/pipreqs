# pipreqs - System-Aware Python Dependency Scanner

[![Fork](https://img.shields.io/badge/fork-enhanced-blue)](https://github.com/bndr/pipreqs)
[![Python](https://img.shields.io/badge/python-3.9+-blue)](https://www.python.org)
[![Ubuntu](https://img.shields.io/badge/ubuntu-20.04+-orange)](https://ubuntu.com)

A modernized version of pipreqs that integrates system package detection for more efficient Python development environments.

## Background

Traditional Python dependency management treats all packages equally, leading to:
- Redundant installations of packages available through system package managers
- Larger virtual environments with unnecessary compilation overhead
- Missed opportunities for leveraging pre-compiled, OS-maintained packages

This version addresses these inefficiencies by checking system package availability before defaulting to PyPI, particularly valuable in modern agentic development workflows where rapid environment setup is crucial.

## Key Differences from Traditional Approach

### Historical Method
```bash
# Standard pipreqs workflow
pipreqs /path/to/project
pip install -r requirements.txt  # Everything via pip, regardless of system availability
```

### System-Aware Method
```bash
# Enhanced pipreqs workflow
pipreqs /path/to/project --system-packages --categorize

# Results in optimized installation strategy:
# sudo apt install python3-numpy python3-pandas    # System packages
# pipx install black flake8                        # CLI tools
# pip install custom-internal-package              # Project-specific only
```

## Installation

```bash
git clone https://github.com/JOravetz/pipreqs.git
cd pipreqs
pip install -e .
```

## Usage

### Basic Usage (Backward Compatible)
```bash
pipreqs /path/to/project
```

### Enhanced Usage
```bash
# Generate system-aware categorization
pipreqs /path/to/project --system-packages --categorize

# Output specific formats
pipreqs /path/to/project --output-format apt     # apt install commands
pipreqs /path/to/project --output-format json    # JSON with metadata
```

## Agentic Development Environment Setup

Modern development increasingly relies on rapid environment provisioning. Here's how this approach improves efficiency:

### Traditional Environment Setup
```bash
# Time-consuming approach
python -m venv project_env
source project_env/bin/activate
pip install numpy pandas matplotlib flask black pytest
# Wait for compilation, downloads, dependency resolution...
```

### Efficient System-Aware Setup
```bash
# Step 1: System packages (instant, pre-compiled)
sudo apt install python3-numpy python3-pandas python3-matplotlib python3-flask

# Step 2: CLI tools (isolated)
pipx install black pytest

# Step 3: Project-specific only
uv init project_name
cd project_name
uv add custom-package

# Step 4: Ready for agentic development
claude-code  # or other AI development tools
```

### Integration with Claude Code

This approach is particularly effective with agentic development tools:

```bash
# Rapid setup for Claude Code sessions
# Create and enter project directory
mkdir ai-project
cd ai-project

# Initialize uv project (creates .venv automatically)
uv init .

# Analyze existing codebase dependencies (if there is existing code)
pipreqs . --system-packages --categorize > setup_plan.txt

# Install system packages
sudo apt install $(grep "apt install" setup_plan.txt | cut -d' ' -f3-)

# Install global tools with pipx
pipx install $(grep "pipx install" setup_plan.txt | cut -d' ' -f3-)

# Add Python dependencies to the uv project
uv add $(grep "pip install" setup_plan.txt | cut -d' ' -f3-)

# Activate the uv environment
source .venv/bin/activate

# Start AI-assisted development
claude-code
```

## Benefits for Modern Development

### Resource Efficiency
- **Reduced bandwidth**: System packages eliminate redundant downloads
- **Faster setup**: Pre-compiled packages vs. source compilation
- **Smaller environments**: Virtual environments contain only project-specific code

### Development Velocity
- **Quick iterations**: Faster environment recreation for testing
- **Consistent baselines**: System packages provide stable foundation
- **Tool isolation**: CLI tools via pipx prevent version conflicts

### Infrastructure Alignment
- **Container optimization**: Smaller Docker images using system packages
- **CI/CD efficiency**: Faster pipeline execution with cached system packages
- **Deployment consistency**: Same packages across development and production

## Technical Implementation

The system detection works by:

1. **Scanning**: Analyzes Python imports in project files
2. **Mapping**: Checks internal database of Python package → system package mappings
3. **Verification**: Uses `apt-cache` to confirm package availability
4. **Categorization**: Applies best practices for package management (system/cli/project)

## Testing

The implementation includes comprehensive testing across multiple dimensions:

```bash
# Run test suite
./scripts/test_all_fixed.sh

# Tests cover:
# - System package detection accuracy
# - Performance with large codebases  
# - Integration with existing pipreqs functionality
# - Cross-environment compatibility
```

## Supported Environments

- **Primary**: Ubuntu 20.04+, Debian 11+
- **Testing**: Other apt-based distributions
- **Fallback**: All systems (disables system detection, functions as standard pipreqs)

## Limitations and Considerations

- System package detection currently focuses on apt-based distributions
- Package version constraints may differ between system and PyPI versions
- Some specialized packages may not have system equivalents
- Requires appropriate permissions for system package installation

## Contributing

Contributions welcome, particularly:
- Additional package mappings for the apt database
- Support for other package managers (dnf, pacman, homebrew)
- Integration testing across different environments
- Performance optimizations for large codebases

## Development Environment Testing

To ensure robust cross-environment functionality:

```bash
# Test on fresh Ubuntu installation
docker run -it ubuntu:22.04
apt update && apt install python3 python3-pip git
# ... test installation and functionality

# Test with existing pipreqs projects
git clone https://github.com/some-python-project
./pipreqs some-python-project --system-packages --categorize
```

## License

Apache 2.0 License - maintains compatibility with original pipreqs licensing.

## Acknowledgments

- Original pipreqs implementation by [@bndr](https://github.com/bndr)
- Motivated by efficiency requirements in modern agentic development workflows
- Testing and validation across diverse Ubuntu/Debian environments

## Fork Information

This is an enhanced fork of the original [pipreqs](https://github.com/bndr/pipreqs) 
with system package awareness added. The core functionality remains compatible 
with the original while adding modern dependency management features.

### Key Enhancements in This Fork:
- System package detection via apt-cache
- Smart categorization (apt/pipx/pip)
- Multiple output formats
- Integration with modern tools (uv, Claude Code)
