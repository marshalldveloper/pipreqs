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
            sys.executable, '-m', 'pipreqs.pipreqs', self.test_dir, '--print'
        ], capture_output=True, text=True)
        
        self.assertEqual(result.returncode, 0)
        self.assertIn('numpy', result.stdout)
        # Could be 'requests' or 'Requests' depending on PyPI response
        self.assertTrue('requests' in result.stdout.lower())
    
    def test_system_packages_flag(self):
        """Test --system-packages flag"""
        result = subprocess.run([
            sys.executable, '-m', 'pipreqs.pipreqs', self.test_dir, 
            '--system-packages', '--print'
        ], capture_output=True, text=True)
        
        self.assertEqual(result.returncode, 0)
        # Should detect system packages
        self.assertIn('numpy', result.stdout)
    
    def test_categorized_output(self):
        """Test --categorize flag"""
        result = subprocess.run([
            sys.executable, '-m', 'pipreqs.pipreqs', self.test_dir,
            '--categorize', '--print'
        ], capture_output=True, text=True)
        
        self.assertEqual(result.returncode, 0)
        self.assertIn('# System packages', result.stdout)
        self.assertIn('# Developer tools', result.stdout)
    
    def test_apt_output_format(self):
        """Test --output-format apt"""
        result = subprocess.run([
            sys.executable, '-m', 'pipreqs.pipreqs', self.test_dir,
            '--system-packages', '--output-format', 'apt', '--print'
        ], capture_output=True, text=True)
        
        self.assertEqual(result.returncode, 0)
        self.assertIn('sudo apt install', result.stdout)
        self.assertIn('python3-', result.stdout)  # Should have system packages

if __name__ == '__main__':
    unittest.main()
