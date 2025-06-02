#!/bin/bash
# Run all tests for pipreqs modernization

echo "🧪 Running pipreqs test suite..."

# Unit tests
echo "=== Unit Tests ==="
uv run python -m pytest tests/test_system_detector.py -v

# Integration tests  
echo "=== Integration Tests ==="
uv run python -m pytest tests/test_integration.py -v

# System tests (may skip on non-Linux)
echo "=== System Tests ==="
uv run python -m pytest tests/test_system.py -v

# Performance tests
echo "=== Performance Tests ==="
uv run python -m pytest tests/test_performance.py -v

echo "✅ All tests completed!"
