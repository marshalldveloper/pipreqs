#!/bin/bash

# Complete Claude Code Setup for pipreqs Modernization
# Run this script from the pipreqs directory

set -e

# Ensure we're in the right directory
if [[ ! -f "pyproject.toml" ]] || [[ ! -d "pipreqs" ]]; then
    echo "❌ Error: This script must be run from the pipreqs project directory"
    echo "Expected files: pyproject.toml, pipreqs/ directory"
    exit 1
fi

echo "🚀 Setting up Claude Code environment for pipreqs modernization..."
echo "Working directory: $(pwd)"

# Step 1: Create development documentation structure
echo "📁 Creating documentation structure..."
mkdir -p .claude/{context,analysis,goals,reference}
mkdir -p development/{fixes,features,tests}

# Step 2: Create main project context
echo "📋 Creating project context..."
cat > .claude/context/project_overview.md << 'EOF'
# pipreqs Modernization Project

## Project Goal
Modernize pipreqs to support system-aware Python package management and current best practices.

## Current State Analysis
- **Location**: /home/jjoravet/pipreqs
- **Type**: Existing Python package for dependency scanning
- **Dependencies**: 92 packages currently, but only 4 actually needed
- **Main Issues**: Regex SyntaxWarnings, no system package awareness, dependency bloat

## Key Files
- `pipreqs/pipreqs.py` - Main module with core logic
- `pipreqs/__init__.py` - Package initialization
- `pyproject.toml` - uv-managed dependencies
- `tests/` - Test suite

## Core Dependencies (Analyzed)
All 4 core dependencies are available via apt:
- docopt → python3-docopt (CLI parsing)
- nbconvert → python3-nbconvert (Jupyter support)  
- requests → python3-requests (HTTP client)
- yarg → python3-yarg (PyPI API wrapper)
EOF

# Step 3: Create technical analysis
echo "🔍 Creating technical analysis..."
cat > .claude/analysis/dependency_analysis.md << 'EOF'
# Dependency Analysis Results

## Current Bloat vs Reality
- **Current uv tree**: 92 packages
- **Actually needed**: 4 packages
- **System availability**: 100% (all 4 available via apt)

## Clean Dependencies Found
```
docopt      → python3-docopt
nbconvert   → python3-nbconvert  
requests    → python3-requests
yarg        → python3-yarg
```

## Issues Identified
1. **Regex SyntaxWarnings**: Old-style patterns in pipreqs.py
2. **No system awareness**: Always queries PyPI
3. **Dependency bloat**: Massive optional dependencies
4. **No categorization**: Treats all packages the same

## Modernization Opportunities
- System-first package detection
- Smart categorization (apt/pipx/pip)
- Multiple output formats
- Offline mode capability
EOF

# Step 4: Create modernization goals
echo "🎯 Creating modernization roadmap..."
cat > .claude/goals/modernization_roadmap.md << 'EOF'
# pipreqs Modernization Roadmap

## Phase 1: Critical Fixes (Immediate)
- [ ] Fix regex SyntaxWarning patterns
- [ ] Update deprecated code patterns
- [ ] Clean up import statements
- [ ] Add proper error handling

## Phase 2: System Integration (Core Feature)
- [ ] Add system package detection (apt-cache/dpkg)
- [ ] Implement package categorization logic
- [ ] Add system-first query logic
- [ ] Create package name mapping system

## Phase 3: Enhanced Output (User Experience)
- [ ] Generate multiple requirement files
- [ ] Create installation scripts
- [ ] Add CLI flags for new features
- [ ] Implement progress indicators

## Phase 4: Modern Features (Future)
- [ ] Add pyproject.toml support
- [ ] Implement dependency conflict detection
- [ ] Add security vulnerability scanning
- [ ] Create Docker integration

## Success Metrics
- ✅ Zero SyntaxWarnings
- ✅ System packages detected and used
- ✅ Reduced installation complexity
- ✅ Backward compatibility maintained
EOF

# Step 5: Copy reference implementations if they exist
echo "📂 Copying reference implementations..."
if [[ -f "../scan_imports.sh" ]]; then
    cp ../scan_imports.sh .claude/reference/
    echo "✅ Copied scan_imports.sh"
else
    echo "⚠️  ../scan_imports.sh not found - you may need to copy it manually"
fi

if [[ -f "../check_packages.sh" ]] || [[ -f "../check_packages_v2.sh" ]]; then
    cp ../check_packages*.sh .claude/reference/ 2>/dev/null || true
    echo "✅ Copied package checker scripts"
else
    echo "⚠️  Package checker scripts not found - you may need to copy them manually"
fi

# Step 6: Copy analysis results if they exist
echo "📊 Copying analysis results..."
if [[ -f "pipreqs_actual_imports.txt" ]]; then
    cp pipreqs_actual_imports.txt .claude/analysis/
    echo "✅ Copied import analysis results"
fi

# Create system package analysis
cat > .claude/analysis/system_packages.txt << 'EOF'
# System Package Analysis Results

## ALL core dependencies available via apt:
sudo apt install \
    python3-docopt \
    python3-nbconvert \
    python3-requests \
    python3-yarg

## Package Mappings:
- docopt → python3-docopt
- nbconvert → python3-nbconvert  
- requests → python3-requests
- yarg → python3-yarg

## Impact:
- 100% system-native installation possible
- Zero pip dependencies required for core functionality
- Massive reduction in installation complexity
EOF

# Step 7: Create development workspace
echo "🛠️  Creating development workspace..."
cat > development/implementation_plan.md << 'EOF'
# Implementation Plan

## Immediate Tasks
1. **Analyze pipreqs/pipreqs.py structure**
   - Identify main functions
   - Find regex patterns causing warnings
   - Map PyPI query locations

2. **Fix Technical Debt**
   - Update regex patterns to use raw strings
   - Fix any deprecated API usage
   - Improve error handling

3. **Add System Detection**
   - Integrate apt-cache checking before PyPI queries
   - Add package name mapping logic
   - Implement categorization system

## Integration Points
- `get_all_imports()` - enhance import detection
- `get_pkg_names()` - add system package checking
- Main CLI - add new flags and options

## Reference Code
- `.claude/reference/scan_imports.sh` - import detection logic
- `.claude/reference/check_packages.sh` - system package detection
EOF

# Step 8: Create test script
echo "🧪 Creating test scripts..."
cat > development/test_current_issues.py << 'EOF'
#!/usr/bin/env python3
"""Test script to identify current pipreqs issues"""

import warnings
import sys
import os

def test_syntax_warnings():
    """Capture syntax warnings from pipreqs import"""
    print("=== Testing for SyntaxWarnings ===")
    warnings.simplefilter('always')
    
    try:
        import pipreqs.pipreqs as p
        print("✅ Import successful")
        return True
    except SyntaxWarning as e:
        print(f"❌ SyntaxWarning: {e}")
        return False
    except Exception as e:
        print(f"❌ Other error: {e}")
        return False

def test_current_functionality():
    """Test current pipreqs functionality"""
    print("\n=== Testing Current Functionality ===")
    try:
        import pipreqs.pipreqs as p
        # Test if main functions exist
        print(f"✅ Main module loaded: {p.__file__}")
        
        # Check for main functions
        functions_to_check = ['get_all_imports', 'get_pkg_names', 'main']
        for func_name in functions_to_check:
            if hasattr(p, func_name):
                print(f"✅ {func_name} function exists")
            else:
                print(f"❌ {func_name} function missing")
        
        return True
    except Exception as e:
        print(f"❌ Functionality test failed: {e}")
        return False

def analyze_main_file():
    """Analyze the main pipreqs.py file"""
    print("\n=== Analyzing pipreqs.py ===")
    main_file = "pipreqs/pipreqs.py"
    
    if not os.path.exists(main_file):
        print(f"❌ {main_file} not found")
        return False
    
    with open(main_file, 'r') as f:
        content = f.read()
        lines = content.split('\n')
    
    print(f"📊 File stats:")
    print(f"   Lines: {len(lines)}")
    print(f"   Characters: {len(content)}")
    
    # Look for potential regex issues
    import re
    regex_issues = []
    for i, line in enumerate(lines, 1):
        if '\\\\' in line and ('\\s' in line or '\\d' in line or '\\w' in line):
            regex_issues.append((i, line.strip()))
    
    if regex_issues:
        print(f"⚠️  Found {len(regex_issues)} potential regex issues:")
        for line_num, line in regex_issues[:5]:  # Show first 5
            print(f"   Line {line_num}: {line}")
    else:
        print("✅ No obvious regex issues found")
    
    return True

if __name__ == "__main__":
    print("🔍 pipreqs Current State Analysis")
    print("=" * 40)
    
    success = True
    success &= test_syntax_warnings()
    success &= test_current_functionality() 
    success &= analyze_main_file()
    
    print("\n" + "=" * 40)
    if success:
        print("✅ Analysis complete - ready for modernization!")
    else:
        print("❌ Issues found - modernization needed!")
EOF

chmod +x development/test_current_issues.py

# Step 9: Create the comprehensive Claude Code prompt
echo "💬 Creating Claude Code prompt..."
cat > .claude/claude_code_prompt.md << 'EOF'
# Claude Code Development Session: pipreqs Modernization

## PROJECT CONTEXT
I'm modernizing the pipreqs Python package to support system-aware dependency management and current best practices.

**Project Location**: `/home/jjoravet/pipreqs`
**Type**: Existing Python package for scanning imports and generating requirements
**Goal**: Add system package awareness and fix technical debt

## CRITICAL ANALYSIS COMPLETED
✅ **Clean dependency analysis**: Only 4 packages actually needed (not 92!)
✅ **System availability confirmed**: ALL 4 core deps available via apt
✅ **Integration opportunity**: Can make pipreqs 100% system-native

### Core Dependencies (All Available via apt)
```bash
sudo apt install python3-docopt python3-nbconvert python3-requests python3-yarg
```

## CURRENT ISSUES IDENTIFIED
1. **SyntaxWarnings**: Regex patterns in pipreqs.py using old-style escapes
2. **No system awareness**: Always queries PyPI even for apt-available packages  
3. **Dependency bloat**: 92 packages when 4 are sufficient
4. **No categorization**: All packages treated as pip dependencies

## MODERNIZATION GOALS
1. **Fix immediate issues**: Eliminate SyntaxWarnings
2. **Add system detection**: Check apt-cache before PyPI queries
3. **Smart categorization**: Generate apt/pipx/pip requirement lists
4. **Maintain compatibility**: Keep existing CLI behavior as default

## KEY FILES TO EXAMINE
- `pipreqs/pipreqs.py` - Main logic (needs regex fixes + system detection)
- `pipreqs/__init__.py` - Package initialization  
- `pyproject.toml` - Dependency management
- `tests/` - Test suite

## REFERENCE IMPLEMENTATIONS
I have working reference implementations in `.claude/reference/`:
- `scan_imports.sh` - Clean import detection logic
- `check_packages.sh` - System package detection using apt-cache/dpkg

## DEVELOPMENT WORKSPACE
- `.claude/` - Complete project documentation
- `development/` - Implementation workspace
- `development/test_current_issues.py` - Current state analysis

## IMMEDIATE DEVELOPMENT TASKS
1. **Analyze current architecture**: Examine pipreqs.py structure and main functions
2. **Fix SyntaxWarnings**: Update regex patterns causing warnings
3. **Plan integration**: Identify where to add system package detection
4. **Design new features**: Plan CLI enhancements for system-aware output

## SUCCESS CRITERIA
- ✅ Zero SyntaxWarnings when importing pipreqs
- ✅ System packages detected before PyPI queries
- ✅ Multiple output formats (requirements-apt.txt, requirements.txt, install scripts)
- ✅ Backward compatibility maintained
- ✅ Installation time reduced (system packages vs pip)

## DEVELOPMENT APPROACH
Start with analysis and immediate fixes, then systematically add system awareness features while maintaining backward compatibility.

Ready to begin systematic modernization of pipreqs!
EOF

# Step 10: Run initial analysis
echo "🔍 Running initial analysis..."
echo ""
uv run python development/test_current_issues.py

# Step 11: Show project structure
echo ""
echo "📁 Project structure created:"
tree .claude/ development/ -I "__pycache__|*.pyc" 2>/dev/null || {
    echo ".claude/"
    find .claude -type f | sed 's/^/  /'
    echo "development/"
    find development -type f | sed 's/^/  /'
}

# Step 12: Final setup verification
echo ""
echo "✅ Claude Code setup complete!"
echo ""
echo "🚀 Next steps:"
echo "1. Run: claude-code"
echo "2. Use the prompt from: .claude/claude_code_prompt.md"
echo "3. Start with: 'Let's examine pipreqs/pipreqs.py to understand the current architecture and identify specific issues that need fixing.'"
echo ""
echo "📋 Quick reference:"
echo "- Project docs: .claude/"
echo "- Analysis results: .claude/analysis/"
echo "- Development workspace: development/"
echo "- Test current state: uv run python development/test_current_issues.py"
