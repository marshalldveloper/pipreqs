#!/bin/bash
# Test script for pipreqs system-aware features

echo "🧪 Running pipreqs test suite..."

# Run all system-aware tests
echo "=== Running system detector tests ==="
uv run python -m pytest tests/test_system_detector.py -v

echo -e "\n=== Running integration tests ==="
uv run python -m pytest tests/test_integration.py -v

echo -e "\n=== Running system environment tests ==="
uv run python -m pytest tests/test_system.py -v

echo -e "\n=== Running performance tests ==="
uv run python -m pytest tests/test_performance.py -v

echo -e "\n✅ All tests completed!"