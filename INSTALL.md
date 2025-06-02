# Installation Guide for pipreqs

## Quick Install

### For most users (using pipx - recommended for CLI tools)

```bash
pipx install pipreqs
```

### Traditional pip install

```bash
pip install pipreqs
```

## Development Installation

If you want to contribute to pipreqs or modify it for your needs:

### 1. Clone the repository

```bash
git clone https://github.com/JOravetz/pipreqs.git
cd pipreqs
```

### 2. Install in development mode

#### Using Poetry (recommended for development)

```bash
poetry install --with dev
```

#### Using pip

```bash
pip install -e .
```

#### For modern Python environments (Ubuntu 24.04+, etc.)

If you get an "externally-managed-environment" error:

```bash
# Option 1: Use pipx for editable install
pipx install -e .

# Option 2: Create a virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -e .

# Option 3: Force install (not recommended)
pip install --break-system-packages -e .
```

## Installation without Jupyter support

If you don't need Jupyter notebook scanning:

```bash
pip install --no-deps pipreqs
pip install yarg==0.1.9 docopt==0.6.2
```

## Verify Installation

```bash
# Check if pipreqs is installed
pipreqs --version

# Get help
pipreqs --help
```

## Common Issues

### 1. Command not found

Make sure your Python scripts directory is in PATH:

```bash
# For user installations
export PATH="$HOME/.local/bin:$PATH"

# Add to your ~/.bashrc or ~/.zshrc to make permanent
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

### 2. Permission denied

Use `--user` flag or pipx:

```bash
pip install --user pipreqs
# or
pipx install pipreqs
```

### 3. Python version conflicts

pipreqs requires Python 3.9+. Check your version:

```bash
python --version
```

## Uninstalling

```bash
# If installed with pip
pip uninstall pipreqs

# If installed with pipx
pipx uninstall pipreqs
```