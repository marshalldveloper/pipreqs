#!/usr/bin/env python3
"""Validate the actual pipreqs modernization implementation"""

def test_system_detector():
    print("🔍 Testing SystemPackageDetector...")
    try:
        from pipreqs.system_detector import SystemPackageDetector
        detector = SystemPackageDetector()
        
        # Test basic functionality
        result = detector.categorize_package('numpy')
        print(f"✅ categorize_package('numpy'): {result}")
        
        # Test multiple packages
        test_packages = ['numpy', 'black', 'unknown-pkg']
        for pkg in test_packages:
            result = detector.categorize_package(pkg)
            print(f"   {pkg}: {result}")
        
        print("✅ SystemPackageDetector working!")
        return True
    except Exception as e:
        print(f"❌ SystemPackageDetector error: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_cli_integration():
    print("\n🔍 Testing CLI integration...")
    import subprocess
    import tempfile
    import sys
    
    try:
        # Create test project
        with tempfile.TemporaryDirectory() as tmpdir:
            test_file = f"{tmpdir}/test.py"
            with open(test_file, 'w') as f:
                f.write("import numpy\nimport requests\n")
            
            # Test basic pipreqs
            print("  Testing basic pipreqs...")
            result = subprocess.run([
                sys.executable, '-m', 'pipreqs.pipreqs', tmpdir, '--print'
            ], capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                print("✅ Basic pipreqs CLI working!")
                print(f"   Output preview: {result.stdout[:100]}...")
            else:
                print(f"❌ CLI error (code {result.returncode}): {result.stderr}")
                return False
                
            # Test with --categorize
            print("\n  Testing --categorize flag...")
            result = subprocess.run([
                sys.executable, '-m', 'pipreqs.pipreqs', tmpdir, '--print', '--categorize'
            ], capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                print("✅ --categorize flag working!")
                if '# System packages' in result.stdout:
                    print("✅ Categorized output format confirmed!")
            else:
                print(f"❌ --categorize error: {result.stderr}")
                
            return True
    except Exception as e:
        print(f"❌ CLI test error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    print("🚀 Validating pipreqs modernization implementation...")
    
    detector_works = test_system_detector()
    cli_works = test_cli_integration()
    
    if detector_works and cli_works:
        print("\n🎉 Implementation validation successful!")
        print("✅ Ready for testing!")
    else:
        print("\n⚠️  Implementation needs fixes")