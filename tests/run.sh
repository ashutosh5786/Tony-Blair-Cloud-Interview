#!/bin/bash

set -e

echo "🧪 [tests] Running unit tests..."

pip install -r ../serving/requirements.txt
pytest .

echo "✅ [tests] All tests passed."
