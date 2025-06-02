#!/usr/bin/env python3
"""Performance tests for system detection using pytest-benchmark"""

import os
import pytest
from pipreqs.system_detector import SystemPackageDetector


class TestPerformance:
    def setup_method(self):
        self.detector = SystemPackageDetector()
        # Large package list for testing
        self.large_package_list = [
            'numpy', 'pandas', 'matplotlib', 'scipy', 'scikit-learn',
            'requests', 'flask', 'django', 'fastapi', 'sqlalchemy',
            'black', 'flake8', 'mypy', 'pytest', 'poetry',
            'tensorflow', 'torch', 'transformers', 'unknown-pkg-1',
            'unknown-pkg-2', 'unknown-pkg-3'
        ] * 5  # 105 packages total
    
    def test_categorization_performance(self, benchmark):
        """Test that categorization is fast even for large package lists"""
        # Convert to proper format for categorize_packages
        package_dicts = [{'name': pkg, 'version': '1.0'} for pkg in self.large_package_list]
        
        # Benchmark the categorization
        result = benchmark(self.detector.categorize_packages, package_dicts)
        
        # Verify results are correct
        assert 'apt' in result
        assert 'pipx' in result
        assert 'pip' in result

    def test_mapping_lookup_performance(self, benchmark):
        """Test that mapping lookups are fast"""
        def lookup_packages():
            for _ in range(1000):
                self.detector.categorize_package('numpy')
                self.detector.categorize_package('unknown-package')
        
        # Benchmark the lookups
        benchmark(lookup_packages)
