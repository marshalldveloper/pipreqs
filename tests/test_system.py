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
                ], capture_output=True, text=True)
                # Don't fail if not found, just log
                if result.returncode != 0:
                    print(f"Note: {pkg} not found via apt-cache")

if __name__ == '__main__':
    unittest.main()
