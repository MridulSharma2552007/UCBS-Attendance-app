#!/bin/bash

echo "
╔══════════════════════════════════════╗
║   UCBS ATTENDANCE APP DEPLOYMENT     ║
╚══════════════════════════════════════╝
"

# Default to WASM, allow override with argument
BUILD_TYPE=${1:-wasm}

if [ "$BUILD_TYPE" = "js" ]; then
    echo "🔨 Building Flutter web app (JavaScript)..."
    flutter build web --release
elif [ "$BUILD_TYPE" = "wasm" ]; then
    echo "🔨 Building Flutter web app (WASM)..."
    flutter build web --release --wasm
else
    echo "❌ Invalid build type. Use 'js' or 'wasm'"
    exit 1
fi

if [ $? -eq 0 ]; then
    echo "
✅ Build successful!
    "
else
    echo "
❌ Build failed!
    "
    exit 1
fi

echo "🚀 Deploying to Vercel..."
cd build/web
vercel --prod

echo "
╔══════════════════════════════════════╗
║      DEPLOYMENT COMPLETE! 🎉         ║
╚══════════════════════════════════════╝
" 
