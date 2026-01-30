#!/bin/bash
# Simple test to verify make test works

echo "Running simple test..."
if [ 1 -eq 1 ]; then
    echo "PASS: Basic assertion works"
    exit 0
else
    echo "FAIL: Something is wrong"
    exit 1
fi
