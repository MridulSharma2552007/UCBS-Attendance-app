#!/bin/bash

echo "
╔══════════════════════════════════════╗
║   UCBS ATTENDANCE APP DEPLOYMENT     ║
╚══════════════════════════════════════╝
"

echo "🔨 Building Flutter web app..."
flutter build web --release

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
