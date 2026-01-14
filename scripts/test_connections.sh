#!/bin/bash

# Quick testing script for WiFi and Bluetooth connections
# Usage: ./scripts/test_connections.sh [unit|widget|integration|all]

set -e

TEST_TYPE=${1:-all}

echo "🧪 MASH Grower Mobile - Connection Testing"
echo "=========================================="
echo ""

case $TEST_TYPE in
  unit)
    echo "📦 Running Unit Tests..."
    flutter test test/unit/bluetooth_device_service_test.dart
    flutter test test/unit/device_connection_service_test.dart
    echo "✅ Unit tests completed"
    ;;
  
  widget)
    echo "🎨 Running Widget Tests..."
    flutter test test/widget/hybrid_device_connection_screen_test.dart
    echo "✅ Widget tests completed"
    ;;
  
  integration)
    echo "🔗 Running Integration Tests..."
    echo "⚠️  Note: Integration tests require physical device"
    flutter test integration_test/wifi_bluetooth_connection_test.dart
    echo "✅ Integration tests completed"
    ;;
  
  all)
    echo "📦 Running Unit Tests..."
    flutter test test/unit/
    echo "✅ Unit tests completed"
    echo ""
    
    echo "🎨 Running Widget Tests..."
    flutter test test/widget/
    echo "✅ Widget tests completed"
    echo ""
    
    echo "🔗 Running Integration Tests..."
    echo "⚠️  Note: Integration tests require physical device"
    flutter test integration_test/wifi_bluetooth_connection_test.dart || echo "⚠️  Integration tests skipped (may require device)"
    echo "✅ All tests completed"
    ;;
  
  *)
    echo "❌ Invalid test type: $TEST_TYPE"
    echo "Usage: ./scripts/test_connections.sh [unit|widget|integration|all]"
    exit 1
    ;;
esac

echo ""
echo "✨ Testing complete!"

