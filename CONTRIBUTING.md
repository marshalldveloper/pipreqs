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
