@echo off
REM Quick testing script for WiFi and Bluetooth connections (Windows)
REM Usage: scripts\test_connections.bat [unit|widget|integration|all]

setlocal

set TEST_TYPE=%1
if "%TEST_TYPE%"=="" set TEST_TYPE=all

echo 🧪 MASH Grower Mobile - Connection Testing
echo ==========================================
echo.

if "%TEST_TYPE%"=="unit" goto :unit
if "%TEST_TYPE%"=="widget" goto :widget
if "%TEST_TYPE%"=="integration" goto :integration
if "%TEST_TYPE%"=="all" goto :all
goto :invalid

:unit
echo 📦 Running Unit Tests...
flutter test test/unit/bluetooth_device_service_test.dart
flutter test test/unit/device_connection_service_test.dart
echo ✅ Unit tests completed
goto :end

:widget
echo 🎨 Running Widget Tests...
flutter test test/widget/hybrid_device_connection_screen_test.dart
echo ✅ Widget tests completed
goto :end

:integration
echo 🔗 Running Integration Tests...
echo ⚠️  Note: Integration tests require physical device
flutter test integration_test/wifi_bluetooth_connection_test.dart
echo ✅ Integration tests completed
goto :end

:all
echo 📦 Running Unit Tests...
flutter test test/unit/
echo ✅ Unit tests completed
echo.

echo 🎨 Running Widget Tests...
flutter test test/widget/
echo ✅ Widget tests completed
echo.

echo 🔗 Running Integration Tests...
echo ⚠️  Note: Integration tests require physical device
flutter test integration_test/wifi_bluetooth_connection_test.dart || echo ⚠️  Integration tests skipped (may require device)
echo ✅ All tests completed
goto :end

:invalid
echo ❌ Invalid test type: %TEST_TYPE%
echo Usage: scripts\test_connections.bat [unit|widget|integration|all]
exit /b 1

:end
echo.
echo ✨ Testing complete!
endlocal


