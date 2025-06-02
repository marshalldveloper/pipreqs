# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is pipreqs?

pipreqs is a tool that generates requirements.txt files based on imports found in a Python project, rather than simply outputting all installed packages (like pip freeze). It analyzes Python source files to identify which external packages are actually imported and queries PyPI to determine their versions.

## Key Commands

### Development Setup
```bash
# Install the project with development dependencies
make install
# or
poetry install --with dev
```

### Running Tests
```bash
# Run tests quickly with default Python
make test
# or
poetry run python -m unittest discover

# Run tests on all Python versions
make test-all
# or
poetry run tox

# Run a specific test
poetry run python -m unittest tests.test_pipreqs.TestPipreqs.test_method_name
```

### Linting
```bash
# Run flake8 linter
make lint
# or
poetry run flake8 pipreqs tests
```

### Building and Publishing
```bash
# Build the package
make build

# Publish to PyPI
make publish

# Publish to test PyPI
make publish-to-test
```

## Code Architecture

### Main Components

1. **pipreqs/pipreqs.py** - Core module containing all main functionality:
   - `get_all_imports()`: Scans Python files and extracts import statements using AST
   - `get_pkg_names()`: Maps import names to PyPI package names
   - `get_imports_info()`: Queries PyPI for package version information
   - `generate_requirements_file()`: Creates the final requirements.txt
   - `init()`: Main entry point that orchestrates the entire process

2. **pipreqs/mapping** - JSON file containing mappings between import names and PyPI package names (e.g., cv2 → opencv-python)

3. **pipreqs/stdlib** - Text file listing Python standard library modules to exclude from requirements

### Key Features
- Supports custom PyPI servers
- Can scan Jupyter notebooks (requires nbconvert)
- Supports different versioning schemes (compat ~=, gt >=, no-pin)
- Can diff and clean existing requirements.txt files
- Handles encoding issues and symbolic links
- Supports proxy configurations

### Testing
- Tests are in `tests/` directory
- Test data files are in `tests/_data*/` directories
- Uses unittest framework
- Tox configuration supports Python 3.9-3.13 and PyPy3

### Dependencies
- Main runtime: yarg, docopt, nbconvert (optional), ipython (optional)
- Development: flake8, tox, coverage, sphinx