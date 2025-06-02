#!/bin/bash

# pipreqs Professional Distribution Setup
# Prepares the modernized pipreqs for GitHub distribution

set -e

echo "🚀 Preparing pipreqs for professional distribution..."

# Check we're in the right place
if [[ ! -f "pipreqs/system_detector.py" ]] || [[ ! -f "pipreqs/apt_mapping.json" ]]; then
    echo "❌ Error: Modern pipreqs files not found. Run this from the pipreqs project directory."
    exit 1
fi

# Step 1: Integration Testing Setup
echo "🧪 Setting up comprehensive testing framework..."
mkdir -p tests/{unit,integration,system,demo}

# Create comprehensive test suite
cat > tests/test_system_detector.py << 'EOF'
#!/usr/bin/env python3
"""Comprehensive tests for system_detector module"""

import unittest
import json
import tempfile
import os
from unittest.mock import patch, MagicMock
import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from pipreqs.system_detector import SystemPackageDetector

class TestSystemPackageDetector(unittest.TestCase):
    def setUp(self):
        self.detector = SystemPackageDetector()
    
    def test_apt_mapping_loads(self):
        """Test that apt mapping JSON loads successfully"""
        self.assertIsInstance(self.detector.apt_mapping, dict)
        self.assertGreater(len(self.detector.apt_mapping), 50)  # Should have 100+ mappings
    
    def test_known_system_packages(self):
        """Test detection of known system packages"""
        # These should definitely be in the mapping
        known_packages = ['numpy', 'pandas', 'requests', 'flask', 'django']
        for pkg in known_packages:
            with self.subTest(package=pkg):
                self.assertIn(pkg, self.detector.apt_mapping)
    
    def test_categorization_logic(self):
        """Test package categorization"""
        # System packages
        self.assertEqual(self.detector.categorize_package('numpy'), 'apt')
        self.assertEqual(self.detector.categorize_package('requests'), 'apt')
        
        # CLI tools  
        self.assertEqual(self.detector.categorize_package('black'), 'pipx')
        self.assertEqual(self.detector.categorize_package('flake8'), 'pipx')
        
        # Unknown packages should go to pip
        self.assertEqual(self.detector.categorize_package('unknown-pkg-12345'), 'pip')
    
    @patch('subprocess.run')
    def test_system_package_detection(self, mock_run):
        """Test system package availability detection"""
        # Mock apt-cache search success
        mock_run.return_value.returncode = 0
        mock_run.return_value.stdout = "python3-numpy - NumPy package"
        
        result = self.detector.is_system_package_available('numpy')
        self.assertTrue(result)
        
        # Mock apt-cache search failure
        mock_run.return_value.returncode = 1
        result = self.detector.is_system_package_available('unknown-package')
        self.assertFalse(result)
    
    def test_batch_categorization(self):
        """Test batch package categorization"""
        packages = ['numpy', 'pandas', 'black', 'unknown-pkg']
        result = self.detector.categorize_packages(packages)
        
        self.assertIn('apt', result)
        self.assertIn('pipx', result) 
        self.assertIn('pip', result)
        
        self.assertIn('numpy', result['apt'])
        self.assertIn('black', result['pipx'])
        self.assertIn('unknown-pkg', result['pip'])

class TestOutputFormats(unittest.TestCase):
    def setUp(self):
        self.detector = SystemPackageDetector()
        self.sample_packages = ['numpy', 'black', 'unknown-pkg']
    
    def test_requirements_format(self):
        """Test standard requirements.txt format"""
        output = self.detector.generate_requirements(self.sample_packages, 'requirements')
        self.assertIn('numpy', output)
        self.assertIn('black', output)
        self.assertIn('unknown-pkg', output)
    
    def test_apt_format(self):
        """Test apt installation format"""
        output = self.detector.generate_requirements(self.sample_packages, 'apt')
        self.assertIn('sudo apt install', output)
        self.assertIn('python3-numpy', output)
    
    def test_categorized_format(self):
        """Test categorized output format"""
        output = self.detector.generate_requirements(self.sample_packages, 'categorized')
        self.assertIn('SYSTEM PACKAGES', output)
        self.assertIn('CLI APPLICATIONS', output)
        self.assertIn('PROJECT LIBRARIES', output)
    
    def test_json_format(self):
        """Test JSON output format"""
        output = self.detector.generate_requirements(self.sample_packages, 'json')
        data = json.loads(output)
        self.assertIn('apt', data)
        self.assertIn('pipx', data)
        self.assertIn('pip', data)

if __name__ == '__main__':
    unittest.main()
EOF

# Create integration tests
cat > tests/test_integration.py << 'EOF'
#!/usr/bin/env python3
"""Integration tests for modernized pipreqs"""

import unittest
import tempfile
import os
import subprocess
import sys

class TestPipreqsIntegration(unittest.TestCase):
    def setUp(self):
        # Create test project
        self.test_dir = tempfile.mkdtemp()
        self.test_file = os.path.join(self.test_dir, 'test_project.py')
        
        with open(self.test_file, 'w') as f:
            f.write("""
import numpy
import requests
import flask
import black
import unknown_package
""")
    
    def tearDown(self):
        import shutil
        shutil.rmtree(self.test_dir)
    
    def test_basic_functionality(self):
        """Test basic pipreqs functionality still works"""
        result = subprocess.run([
            sys.executable, '-m', 'pipreqs', self.test_dir, '--print'
        ], capture_output=True, text=True)
        
        self.assertEqual(result.returncode, 0)
        self.assertIn('numpy', result.stdout)
        self.assertIn('requests', result.stdout)
    
    def test_system_packages_flag(self):
        """Test --system-packages flag"""
        result = subprocess.run([
            sys.executable, '-m', 'pipreqs', self.test_dir, 
            '--system-packages', '--print'
        ], capture_output=True, text=True)
        
        self.assertEqual(result.returncode, 0)
        # Should detect system packages
        self.assertIn('numpy', result.stdout)
    
    def test_categorized_output(self):
        """Test --categorize flag"""
        result = subprocess.run([
            sys.executable, '-m', 'pipreqs', self.test_dir,
            '--categorize', '--print'
        ], capture_output=True, text=True)
        
        self.assertEqual(result.returncode, 0)
        self.assertIn('SYSTEM PACKAGES', result.stdout)
        self.assertIn('CLI APPLICATIONS', result.stdout)
    
    def test_apt_output_format(self):
        """Test --output-format apt"""
        result = subprocess.run([
            sys.executable, '-m', 'pipreqs', self.test_dir,
            '--output-format', 'apt', '--print'
        ], capture_output=True, text=True)
        
        self.assertEqual(result.returncode, 0)
        self.assertIn('sudo apt install', result.stdout)
        self.assertIn('python3-numpy', result.stdout)

if __name__ == '__main__':
    unittest.main()
EOF

# Create system-level tests
cat > tests/test_system.py << 'EOF'
#!/usr/bin/env python3
"""System-level tests for real Ubuntu environment"""

import unittest
import subprocess
import platform
import os

class TestSystemEnvironment(unittest.TestCase):
    def setUp(self):
        self.is_ubuntu = 'ubuntu' in platform.platform().lower()
    
    @unittest.skipUnless(platform.system() == 'Linux', "Linux-only test")
    def test_apt_cache_available(self):
        """Test that apt-cache is available"""
        result = subprocess.run(['which', 'apt-cache'], capture_output=True)
        self.assertEqual(result.returncode, 0, "apt-cache not found")
    
    @unittest.skipUnless(platform.system() == 'Linux', "Linux-only test")  
    def test_dpkg_available(self):
        """Test that dpkg is available"""
        result = subprocess.run(['which', 'dpkg'], capture_output=True)
        self.assertEqual(result.returncode, 0, "dpkg not found")
    
    def test_system_python_packages(self):
        """Test detection of common system Python packages"""
        # These should be available on most Ubuntu systems
        common_packages = ['python3-setuptools', 'python3-pip']
        
        for pkg in common_packages:
            with self.subTest(package=pkg):
                result = subprocess.run([
                    'apt-cache', 'show', pkg
                ], capture_output=True, stderr=subprocess.DEVNULL)
                # Don't fail if not found, just log
                if result.returncode != 0:
                    print(f"Note: {pkg} not found via apt-cache")

if __name__ == '__main__':
    unittest.main()
EOF

# Create performance tests
cat > tests/test_performance.py << 'EOF'
#!/usr/bin/env python3
"""Performance tests for system detection"""

import unittest
import time
import tempfile
import os
from pipreqs.system_detector import SystemPackageDetector

class TestPerformance(unittest.TestCase):
    def setUp(self):
        self.detector = SystemPackageDetector()
        # Large package list for testing
        self.large_package_list = [
            'numpy', 'pandas', 'matplotlib', 'scipy', 'scikit-learn',
            'requests', 'flask', 'django', 'fastapi', 'sqlalchemy',
            'black', 'flake8', 'mypy', 'pytest', 'poetry',
            'tensorflow', 'torch', 'transformers', 'unknown-pkg-1',
            'unknown-pkg-2', 'unknown-pkg-3'
        ] * 5  # 105 packages total
    
    def test_categorization_performance(self):
        """Test that categorization is fast even for large package lists"""
        start_time = time.time()
        result = self.detector.categorize_packages(self.large_package_list)
        end_time = time.time()
        
        duration = end_time - start_time
        self.assertLess(duration, 1.0, f"Categorization took {duration:.2f}s, should be <1s")
        
        # Verify results
        self.assertIn('apt', result)
        self.assertIn('pipx', result)
        self.assertIn('pip', result)
    
    def test_mapping_lookup_performance(self):
        """Test that mapping lookups are fast"""
        start_time = time.time()
        
        for _ in range(1000):
            self.detector.categorize_package('numpy')
            self.detector.categorize_package('unknown-package')
        
        end_time = time.time()
        duration = end_time - start_time
        self.assertLess(duration, 0.1, f"1000 lookups took {duration:.3f}s, should be <0.1s")

if __name__ == '__main__':
    unittest.main()
EOF

# Step 2: Copy autotrade scripts into project
echo "📂 Integrating autotrade reference scripts..."
mkdir -p scripts/reference

# Check if scripts exist and copy them
if [[ -f "../autotrade/scan_imports.sh" ]]; then
    cp ../autotrade/scan_imports.sh scripts/reference/
    echo "✅ Copied scan_imports.sh from autotrade"
else
    echo "⚠️  scan_imports.sh not found in ../autotrade/"
fi

if [[ -f "../autotrade/check_packages.sh" ]] || [[ -f "../autotrade/check_packages_v2.sh" ]]; then
    cp ../autotrade/check_packages*.sh scripts/reference/ 2>/dev/null || true
    echo "✅ Copied package checker scripts from autotrade"
else
    echo "⚠️  Package checker scripts not found in ../autotrade/"
fi

# Create utility scripts for development
cat > scripts/test_all.sh << 'EOF'
#!/bin/bash
# Run all tests for pipreqs modernization

echo "🧪 Running pipreqs test suite..."

# Unit tests
echo "=== Unit Tests ==="
python -m pytest tests/test_system_detector.py -v

# Integration tests  
echo "=== Integration Tests ==="
python -m pytest tests/test_integration.py -v

# System tests (may skip on non-Linux)
echo "=== System Tests ==="
python -m pytest tests/test_system.py -v

# Performance tests
echo "=== Performance Tests ==="
python -m pytest tests/test_performance.py -v

echo "✅ All tests completed!"
EOF

chmod +x scripts/test_all.sh

# Step 3: Git preparation
echo "📦 Preparing for Git distribution..."

# Create comprehensive .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/
.python-version

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Testing
.pytest_cache/
.coverage
htmlcov/
.tox/
.nox/

# Documentation
docs/_build/

# Temporary files
*.tmp
*.temp
.temp/
temp/

# Development
.claude/
development/
*.log
EOF

# Create modern README.md
cat > README.md << 'EOF'
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
EOF

# Create CONTRIBUTING.md
cat > CONTRIBUTING.md << 'EOF'
# Contributing to Modern pipreqs

Thank you for your interest in contributing to the modernized pipreqs project!

## Development Setup

1. **Clone and setup**:
```bash
git clone https://github.com/yourusername/pipreqs.git
cd pipreqs
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows
pip install -e .[dev]
```

2. **Run tests**:
```bash
./scripts/test_all.sh
```

## Areas for Contribution

### Package Mappings
Help expand `pipreqs/apt_mapping.json` with more Python → system package mappings:

```json
{
  "package-name": "system-package-name",
  "beautifulsoup4": "python3-bs4",
  "pillow": "python3-pil"
}
```

### Distribution Support
- Add support for other package managers (dnf, pacman, etc.)
- Test on different Linux distributions
- Add macOS Homebrew support

### Features
- Dependency conflict detection
- Version constraint handling
- Integration with other tools (Docker, poetry, etc.)

### Testing
- Add test cases for edge cases
- Performance optimization
- Real-world project testing

## Code Style

- Follow PEP 8
- Use type hints where possible
- Add docstrings for public functions
- Keep backward compatibility

## Submitting Changes

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes with tests
4. Run the test suite: `./scripts/test_all.sh`
5. Submit a pull request

## Package Mapping Guidelines

When adding new package mappings:

1. **Verify availability**: Check that the system package exists
2. **Test functionality**: Ensure the system package works equivalently
3. **Check versions**: Note any version differences
4. **Document**: Add comments for non-obvious mappings

## Questions?

Open an issue for discussion before starting major changes.
EOF

# Step 4: Create GitHub Actions workflow
mkdir -p .github/workflows

cat > .github/workflows/test.yml << 'EOF'
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.7, 3.8, 3.9, '3.10', '3.11', '3.12']

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v3
      with:
        python-version: ${{ matrix.python-version }}
    
    - name: Install system dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y python3-dev
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -e .[dev]
        pip install pytest pytest-cov
    
    - name: Run tests
      run: |
        python -m pytest tests/ -v --cov=pipreqs --cov-report=xml
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
        flags: unittests
        name: codecov-umbrella
EOF

echo ""
echo "✅ Professional distribution setup complete!"
echo ""
echo "📁 Created:"
echo "  - Comprehensive test suite (tests/)"
echo "  - Reference scripts integration (scripts/reference/)"  
echo "  - Git configuration (.gitignore)"
echo "  - Professional README.md"
echo "  - Contributing guidelines"
echo "  - GitHub Actions CI/CD"
echo ""
echo "🚀 Next steps:"
echo "1. Run tests: ./scripts/test_all.sh"
echo "2. Initialize git: git init && git add . && git commit -m 'Initial modernized pipreqs'"
echo "3. Create GitHub repo and push"
echo "4. Set up branch protection rules"
echo "5. Enable GitHub Actions"
echo ""
echo "🎯 Ready for professional distribution!"
