#!/usr/bin/env python3
"""Performance tests for system detection"""

import unittest
import time
import tempfile
import os
from pipreqs.system_detector import SystemPackageDetector

# Skip performance tests in CI environments where timing is unreliable
is_ci = os.getenv('CI') == 'true' or os.getenv('GITHUB_ACTIONS') == 'true'

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
    
    @unittest.skipIf(is_ci, "Performance tests skipped in CI environments")
    def test_categorization_performance(self):
        """Test that categorization is fast even for large package lists"""
        # Convert to proper format for categorize_packages
        package_dicts = [{'name': pkg, 'version': '1.0'} for pkg in self.large_package_list]
        
        start_time = time.time()
        result = self.detector.categorize_packages(package_dicts)
        end_time = time.time()
        
        duration = end_time - start_time
        self.assertLess(duration, 1.0, f"Categorization took {duration:.2f}s, should be <1s")
        
        # Verify results
        self.assertIn('apt', result)
        self.assertIn('pipx', result)
        self.assertIn('pip', result)
    
    @unittest.skipIf(is_ci, "Performance tests skipped in CI environments")
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
