# Deployment Guide

## Build Options

### WASM (Default - Recommended)
Better performance for face recognition and heavy computation.

```bash
./deploy.sh wasm
# or just
./deploy.sh
```

**Pros:**
- 30-50% faster for computational tasks
- Better for face vector processing
- Smaller bundle size

**Cons:**
- Requires modern browsers (Chrome 74+, Firefox 79+, Safari 14.1+)

### JavaScript
Better browser compatibility with older devices.

```bash
./deploy.sh js
```

**Pros:**
- Works on older browsers
- Wider device support

**Cons:**
- Slower performance
- Larger bundle size

## Quick Deploy

```bash
# Make script executable
chmod +x deploy.sh

# Deploy with WASM (default)
./deploy.sh

# Or deploy with JavaScript
./deploy.sh js
```

## Environment Setup

Ensure you have:
- Flutter SDK 3.24+
- Vercel CLI installed (`npm install -g vercel`)
- Logged into Vercel (`vercel login`)
