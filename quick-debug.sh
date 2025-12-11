#!/bin/bash

# Quick debug script - checks for common issues

echo "=== ArcSign Quick Debug ==="
echo ""

# 1. Check if USB is detected
echo "[1/5] Checking USB detection..."
USB_PATH="/Volumes/arcsign"
if [ -d "$USB_PATH" ]; then
    echo "✓ USB found at $USB_PATH"
    ls -la "$USB_PATH" | head -5
else
    echo "✗ USB not found at $USB_PATH"
    echo "Available volumes:"
    ls -1 /Volumes/
fi

echo ""

# 2. Check if app_config.enc exists
echo "[2/5] Checking app_config.enc..."
if [ -f "$USB_PATH/app_config.enc" ]; then
    echo "✓ app_config.enc exists"
    ls -lh "$USB_PATH/app_config.enc"
else
    echo "✗ app_config.enc not found (first-time setup)"
fi

echo ""

# 3. Check if Go library is built
echo "[3/5] Checking Go library..."
GO_LIB="dashboard/src-tauri/libarcsign.dylib"
if [ -f "$GO_LIB" ]; then
    echo "✓ Go library exists"
    ls -lh "$GO_LIB"
    echo "Checking FFI symbols..."
    nm "$GO_LIB" | grep -E "(IsFirstTimeSetup|InitializeApp|UnlockApp)" | head -3
else
    echo "✗ Go library not found"
fi

echo ""

# 4. Check Rust build
echo "[4/5] Checking Rust build..."
if [ -f "dashboard/src-tauri/target/debug/ArcSign" ]; then
    echo "✓ Rust binary exists"
    ls -lh dashboard/src-tauri/target/debug/ArcSign
else
    echo "✗ Rust binary not found - needs compilation"
fi

echo ""

# 5. Check running processes
echo "[5/5] Checking running processes..."
TAURI_PID=$(ps aux | grep "ArcSign" | grep -v grep | awk '{print $2}' | head -1)
if [ -n "$TAURI_PID" ]; then
    echo "✓ ArcSign running (PID: $TAURI_PID)"
else
    echo "✗ ArcSign not running"
fi

VITE_PID=$(lsof -ti:5173 2>/dev/null)
if [ -n "$VITE_PID" ]; then
    echo "✓ Vite dev server running (PID: $VITE_PID, port: 5173)"
else
    echo "✗ Vite dev server not running"
fi

echo ""
echo "=== Summary ==="
echo "To start with logging: ./start-dev-with-logs.sh"
echo "To view logs: ./view-logs.sh"
echo "To rebuild Go library: cd dashboard/src-tauri && go build -buildmode=c-shared -o libarcsign.dylib ../../internal/lib/*.go"
