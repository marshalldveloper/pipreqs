#!/usr/bin/env python3
"""Tests for system_detector module"""

import unittest
import json
import tempfile
import os
from unittest.mock import patch, MagicMock
import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from pipreqs.system_detector import SystemPackageDetector, PYTHON_TO_APT_MAPPING, PIPX_PACKAGES

class TestSystemPackageDetector(unittest.TestCase):
    def setUp(self):
        self.detector = SystemPackageDetector()
    
    def test_apt_mapping_loads(self):
        """Test that apt mapping loads successfully"""
        self.assertIsInstance(PYTHON_TO_APT_MAPPING, dict)
        self.assertGreater(len(PYTHON_TO_APT_MAPPING), 5)  # Should have mappings
    
    def test_known_system_packages(self):
        """Test detection of known system packages"""
        # These should definitely be in the mapping
        known_packages = ['numpy', 'requests', 'docopt']
        for pkg in known_packages:
            with self.subTest(package=pkg):
                self.assertIn(pkg, PYTHON_TO_APT_MAPPING)
    
    def test_categorization_logic(self):
        """Test package categorization returns tuple"""
        # System packages - returns tuple (category, apt_package_name)
        category, apt_name = self.detector.categorize_package('numpy')
        self.assertEqual(category, 'apt')
        self.assertEqual(apt_name, 'python3-numpy')
        
        # CLI tools - returns tuple (category, None)
        category, apt_name = self.detector.categorize_package('black')
        self.assertEqual(category, 'pipx')
        self.assertIsNone(apt_name)
        
        # Unknown packages should go to pip
        category, apt_name = self.detector.categorize_package('unknown-pkg-12345')
        self.assertEqual(category, 'pip')
        self.assertIsNone(apt_name)
    
    @patch('subprocess.run')
    def test_check_apt_package(self, mock_run):
        """Test apt package checking"""
        # Mock apt-cache show success
        mock_run.return_value.returncode = 0
        mock_run.return_value.stdout = "Package: python3-numpy"
        
        result = self.detector.check_apt_package('numpy')
        self.assertEqual(result, 'python3-numpy')
        
        # Mock apt-cache show failure
        mock_run.return_value.returncode = 1
        result = self.detector.check_apt_package('nonexistent')
        self.assertIsNone(result)
    
    def test_batch_categorization(self):
        """Test batch package categorization"""
        packages = [
            {'name': 'numpy', 'version': '1.0'},
            {'name': 'pandas', 'version': '2.0'},
            {'name': 'black', 'version': '22.0'},
            {'name': 'unknown-pkg', 'version': None}
        ]
        result = self.detector.categorize_packages(packages)
        
        self.assertIn('apt', result)
        self.assertIn('pipx', result)
        self.assertIn('pip', result)
        
        # Check categorization
        apt_names = [p['name'] for p in result['apt']]
        pipx_names = [p['name'] for p in result['pipx']]
        pip_names = [p['name'] for p in result['pip']]
        
        self.assertIn('numpy', apt_names)
        self.assertIn('black', pipx_names)
        self.assertIn('unknown-pkg', pip_names)


class TestOutputFormats(unittest.TestCase):
    def setUp(self):
        self.detector = SystemPackageDetector()
        self.sample_packages = {
            'apt': [
                {'name': 'numpy', 'version': '1.0', 'system_name': 'python3-numpy', 'installed': True},
                {'name': 'pandas', 'version': '2.0', 'system_name': 'python3-pandas', 'installed': False}
            ],
            'pipx': [
                {'name': 'black', 'version': '22.0'},
                {'name': 'mypy', 'version': '1.0'}
            ],
            'pip': [
                {'name': 'custom-pkg', 'version': '0.1'}
            ]
        }
    
    def test_categorized_format(self):
        """Test categorized output format"""
        output = self.detector.generate_categorized_output(self.sample_packages)
        self.assertIn('# System packages', output)
        self.assertIn('# Developer tools', output)
        self.assertIn('# Python packages', output)
        self.assertIn('python3-numpy', output)
        self.assertIn('black', output)
        self.assertIn('custom-pkg', output)
    
    def test_apt_install_command(self):
        """Test apt install command generation"""
        cmd = self.detector.get_apt_install_command(self.sample_packages['apt'])
        self.assertIn('sudo apt install', cmd)
        self.assertIn('python3-numpy', cmd)
        self.assertIn('python3-pandas', cmd)


if __name__ == '__main__':
    unittest.main()