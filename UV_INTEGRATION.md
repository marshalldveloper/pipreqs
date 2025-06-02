# pipreqs + UV: A Perfect Match for Modern Python Development

## What is UV?

UV is an ultra-fast Python package installer and resolver written in Rust, designed to be a drop-in replacement for pip and pip-tools. It's 10-100x faster than pip and provides better dependency resolution.

## How Enhanced pipreqs Benefits UV Workflows

### 1. **Lightning-Fast Dependency Resolution**

```bash
# Traditional workflow (slow):
pip freeze > requirements.txt  # Includes 200+ packages
pip install -r requirements.txt  # Takes minutes

# pipreqs + UV workflow (fast):
pipreqs . --force  # Generates minimal requirements (5-20 packages)
uv pip install -r requirements.txt  # Takes seconds
```

**Benefit**: UV's speed + pipreqs' minimal dependencies = fastest possible setup

### 2. **Accurate Dependency Sync**

```bash
# UV workspace setup
uv pip sync requirements.txt  # Only installs what's needed

# pipreqs ensures requirements.txt is minimal and accurate
pipreqs . --force --mode compat
```

UV's `sync` command removes packages not in requirements.txt - pipreqs ensures this list is exactly what you need.

### 3. **System Package Integration**

The enhanced system detection in pipreqs helps UV users optimize installations:

```python
# pipreqs now categorizes:
{
    "apt": ["numpy", "scipy"],  # Can use system packages
    "pipx": ["black", "mypy"],   # Global tools
    "pip": ["requests", "flask"]  # Regular pip packages
}
```

UV workflow:
```bash
# Install system packages for performance
sudo apt install python3-numpy python3-scipy

# Install dev tools globally
pipx install black mypy

# Use UV for project dependencies only
uv pip install -r requirements.txt
```

### 4. **Virtual Environment Optimization**

```bash
# Create UV venv with minimal dependencies
uv venv
source .venv/bin/activate

# Generate minimal requirements
pipreqs . --force

# UV installs only what's needed (faster, smaller)
uv pip install -r requirements.txt

# Result: Lightweight venv (MB vs GB)
```

### 5. **Reproducible Builds**

```bash
# Development workflow
pipreqs . --mode compat > requirements.in
uv pip compile requirements.in > requirements.txt
uv pip sync requirements.txt

# Benefits:
# - pipreqs: accurate source dependencies
# - uv compile: locked versions with hashes
# - uv sync: exact reproducible environment
```

### 6. **Faster CI/CD Pipelines**

```yaml
# .github/workflows/test.yml
steps:
  - uses: actions/checkout@v4
  
  - name: Install UV
    run: pip install uv
    
  - name: Generate requirements
    run: pipreqs . --force
    
  - name: Install dependencies (10x faster)
    run: uv pip install -r requirements.txt
    
  # Faster CI builds with minimal dependencies
```

### 7. **Development vs Production Dependencies**

```bash
# Generate different requirement files
pipreqs src/ --savepath requirements.txt
pipreqs tests/ --savepath requirements-test.txt
pipreqs docs/ --savepath requirements-docs.txt

# UV can quickly switch contexts
uv pip sync requirements.txt  # Production only
uv pip sync requirements.txt requirements-test.txt  # With tests
```

### 8. **Dependency Conflict Resolution**

```bash
# pipreqs provides minimal constraints
pipreqs . --mode no-pin > requirements.in

# UV's superior resolver handles conflicts
uv pip compile requirements.in --resolver=backtrack

# Result: Optimal version selection
```

## Practical UV + pipreqs Workflows

### Workflow 1: New Project Setup

```bash
# 1. Create project structure
mkdir my-project && cd my-project
uv venv
source .venv/bin/activate

# 2. Develop your code
# ... write Python files with imports ...

# 3. Generate minimal requirements
pipreqs . --force

# 4. Install with UV (seconds, not minutes)
uv pip install -r requirements.txt
```

### Workflow 2: Adding New Dependencies

```bash
# 1. Add new import in code
echo "import pandas as pd" >> analysis.py

# 2. Update requirements
pipreqs . --force

# 3. Sync with UV (only installs pandas)
uv pip sync requirements.txt
```

### Workflow 3: Cleaning Unused Dependencies

```bash
# 1. Check what's unused
pipreqs --diff requirements.txt .

# 2. Clean requirements
pipreqs --clean requirements.txt .

# 3. UV removes unused packages
uv pip sync requirements.txt
```

### Workflow 4: Multi-Environment Management

```bash
# Base requirements
pipreqs src/ --savepath requirements/base.txt

# Test requirements  
pipreqs tests/ --savepath requirements/test.txt

# UV environments
uv venv --python 3.11 .venv-dev
uv venv --python 3.11 .venv-prod

# Quick environment switching
source .venv-dev/bin/activate
uv pip sync requirements/base.txt requirements/test.txt

source .venv-prod/bin/activate  
uv pip sync requirements/base.txt
```

## Performance Comparison

| Operation | pip + pip freeze | pip + pipreqs | uv + pipreqs |
|-----------|------------------|---------------|--------------|
| Generate requirements | <1s (but 200+ packages) | 2-3s (minimal) | 2-3s (minimal) |
| Fresh install | 60-120s | 30-60s | 3-10s |
| Add one package | 10-20s | 5-10s | 1-2s |
| Remove unused | Manual | Automatic | Automatic |
| Venv size | 500MB-2GB | 100-500MB | 100-500MB |

## Integration with UV Features

### 1. **UV's Parallel Downloads**
- Fewer packages from pipreqs = even faster parallel downloads
- Network bandwidth used efficiently

### 2. **UV's Cache System**
- Smaller dependency set = better cache hit rate
- Less disk space used for cache

### 3. **UV's Resolution Algorithm**
- Minimal constraints from pipreqs = faster resolution
- Fewer potential conflicts to resolve

### 4. **UV's Lock Files**
```bash
# Combine pipreqs accuracy with UV locking
pipreqs . --mode compat > requirements.in
uv pip compile requirements.in --generate-hashes > requirements.lock
```

## Best Practices

1. **Use pipreqs for source truth**
   ```bash
   pipreqs . --force  # Always regenerate from imports
   ```

2. **Use UV for installation**
   ```bash
   uv pip sync requirements.txt  # Fast, deterministic
   ```

3. **Separate concerns**
   ```bash
   pipreqs src/ --savepath requirements/prod.txt
   pipreqs tests/ --savepath requirements/dev.txt
   ```

4. **Version control strategy**
   ```bash
   # Commit both:
   requirements.in   # From pipreqs (source truth)
   requirements.lock # From uv compile (locked versions)
   ```

5. **CI/CD optimization**
   ```yaml
   - run: uv pip install -r requirements.txt --system  # Fastest CI installs
   ```

## Advanced Integration

### Custom UV Configuration

```toml
# pyproject.toml
[tool.uv]
index-url = "https://pypi.org/simple"
system = true  # Use system packages when available

[tool.pipreqs]
mode = "compat"  # Use compatible versions
ignore = ["tests", "docs"]
```

### Makefile Integration

```makefile
# Makefile
.PHONY: deps sync clean

deps:  # Generate minimal requirements
	pipreqs . --force --mode compat

sync: deps  # Install with UV
	uv pip sync requirements.txt

clean:  # Clean unused
	pipreqs --clean requirements.txt .
	uv pip sync requirements.txt

update: # Update all dependencies
	pipreqs . --mode no-pin > requirements.in
	uv pip compile requirements.in --upgrade > requirements.txt
	uv pip sync requirements.txt
```

## Conclusion

The enhanced pipreqs is the perfect companion to UV because:

1. **Speed**: Minimal dependencies = UV installs even faster
2. **Accuracy**: Only real dependencies = cleaner environments  
3. **Size**: Smaller requirements = smaller venvs, faster CI
4. **Compatibility**: System package detection works with UV's system mode
5. **Workflow**: pipreqs for detection, UV for installation - best of both tools

Together, they create the fastest, most accurate Python dependency management workflow available today.