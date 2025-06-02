#!/usr/bin/env python
"""System package detection module for pipreqs.

This module provides functionality to detect if Python packages are available
via system package managers (like apt) before querying PyPI.
"""

import subprocess
import logging
import json
import os
from typing import List, Dict, Optional, Tuple


def load_mappings():
    """Load package mappings from JSON file."""
    mapping_file = os.path.join(os.path.dirname(__file__), 'apt_mapping.json')
    try:
        with open(mapping_file, 'r') as f:
            data = json.load(f)
            return data['mappings'], set(data['pipx_tools'])
    except (FileNotFoundError, json.JSONDecodeError, KeyError) as e:
        logging.debug(f"Could not load apt_mapping.json: {e}")
        # Fallback to minimal hardcoded mappings
        return {
            "requests": "python3-requests",
            "numpy": "python3-numpy",
            "docopt": "python3-docopt",
            "nbconvert": "python3-nbconvert",
            "ipython": "python3-ipython",
            "yarg": "python3-yarg",
        }, {"black", "mypy", "flake8", "poetry", "pipenv"}


# Load mappings at module level
PYTHON_TO_APT_MAPPING, PIPX_PACKAGES = load_mappings()


class SystemPackageDetector:
    """Detects and categorizes Python packages by installation method."""
    
    def __init__(self, use_cache: bool = True):
        self.use_cache = use_cache
        self._apt_cache = {}
        self._dpkg_cache = {}
        
    def check_apt_package(self, package_name: str) -> Optional[str]:
        """Check if a package is available via apt.
        
        Args:
            package_name: The Python package name to check
            
        Returns:
            The apt package name if available, None otherwise
        """
        # First check our mapping (case-insensitive)
        apt_name = PYTHON_TO_APT_MAPPING.get(package_name.lower())
        
        # Special case handling for common variations
        if not apt_name and package_name.lower() == "requests":
            apt_name = "python3-requests"
        elif not apt_name and package_name.lower() == "ipython":
            apt_name = "python3-ipython"
            
        if not apt_name:
            # Try standard python3- prefix
            apt_name = f"python3-{package_name.lower()}"
            
        if self.use_cache and apt_name in self._apt_cache:
            return self._apt_cache[apt_name]
            
        try:
            # Check if package exists in apt
            result = subprocess.run(
                ["apt-cache", "show", apt_name],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            if result.returncode == 0:
                self._apt_cache[apt_name] = apt_name
                return apt_name
            else:
                self._apt_cache[apt_name] = None
                return None
                
        except (subprocess.TimeoutExpired, FileNotFoundError, OSError) as e:
            logging.debug(f"Error checking apt package {apt_name}: {e}")
            return None
            
    def check_installed_dpkg(self, apt_package: str) -> bool:
        """Check if an apt package is currently installed.
        
        Args:
            apt_package: The apt package name to check
            
        Returns:
            True if installed, False otherwise
        """
        if self.use_cache and apt_package in self._dpkg_cache:
            return self._dpkg_cache[apt_package]
            
        try:
            result = subprocess.run(
                ["dpkg", "-l", apt_package],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            # dpkg -l returns 0 even if package not installed, check output
            installed = result.returncode == 0 and f"ii  {apt_package}" in result.stdout
            self._dpkg_cache[apt_package] = installed
            return installed
            
        except (subprocess.TimeoutExpired, FileNotFoundError, OSError) as e:
            logging.debug(f"Error checking dpkg status for {apt_package}: {e}")
            return False
            
    def categorize_package(self, package_name: str) -> Tuple[str, Optional[str]]:
        """Categorize a package by its recommended installation method.
        
        Args:
            package_name: The Python package name
            
        Returns:
            Tuple of (category, system_package_name)
            Categories: 'apt', 'pipx', 'pip'
        """
        # Check if it's available via apt
        apt_package = self.check_apt_package(package_name)
        if apt_package:
            return ('apt', apt_package)
            
        # Check if it's a tool that should use pipx
        if package_name.lower() in [p.lower() for p in PIPX_PACKAGES]:
            return ('pipx', None)
            
        # Default to pip
        return ('pip', None)
        
    def categorize_packages(self, packages: List[Dict[str, str]]) -> Dict[str, List[Dict[str, str]]]:
        """Categorize a list of packages by installation method.
        
        Args:
            packages: List of package dicts with 'name' and 'version' keys
            
        Returns:
            Dict with categories as keys and lists of packages as values
        """
        categorized = {
            'apt': [],
            'pipx': [],
            'pip': []
        }
        
        for pkg in packages:
            category, system_name = self.categorize_package(pkg['name'])
            
            # Create enhanced package info
            enhanced_pkg = pkg.copy()
            if system_name:
                enhanced_pkg['system_name'] = system_name
                enhanced_pkg['installed'] = self.check_installed_dpkg(system_name)
                
            categorized[category].append(enhanced_pkg)
            
        return categorized
        
    def get_apt_install_command(self, packages: List[Dict[str, str]]) -> str:
        """Generate apt install command for system packages.
        
        Args:
            packages: List of package dicts with 'system_name' key
            
        Returns:
            The apt install command string
        """
        apt_packages = [pkg['system_name'] for pkg in packages if 'system_name' in pkg]
        if apt_packages:
            return f"sudo apt install {' '.join(sorted(apt_packages))}"
        return ""
        
    def generate_categorized_output(self, categorized: Dict[str, List[Dict[str, str]]]) -> str:
        """Generate human-readable categorized output.
        
        Args:
            categorized: Dict of categorized packages
            
        Returns:
            Formatted string output
        """
        output = []
        
        if categorized['apt']:
            output.append("# System packages (install with apt)")
            output.append("# " + self.get_apt_install_command(categorized['apt']))
            for pkg in categorized['apt']:
                status = "✓" if pkg.get('installed', False) else "✗"
                output.append(f"# {status} {pkg['system_name']} (Python: {pkg['name']})")
            output.append("")
            
        if categorized['pipx']:
            output.append("# Developer tools (install with pipx)")
            for pkg in categorized['pipx']:
                version = f"=={pkg['version']}" if pkg.get('version') else ""
                output.append(f"# pipx install {pkg['name']}{version}")
            output.append("")
            
        if categorized['pip']:
            output.append("# Python packages (install with pip)")
            for pkg in categorized['pip']:
                version = f"=={pkg['version']}" if pkg.get('version') else ""
                output.append(f"{pkg['name']}{version}")
                
        return "\n".join(output)