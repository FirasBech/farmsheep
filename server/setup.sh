#!/usr/bin/env bash
set -e

echo ""
echo " FarmSheep Server - First-Time Setup"
echo " ====================================="
echo ""

# Check Node.js
if ! command -v node &>/dev/null; then
    echo " [ERROR] Node.js is not installed."
    echo ""
    echo " Install it with one of these commands:"
    echo "   Ubuntu/Debian:  sudo apt install -y nodejs npm"
    echo "   Or use nvm:     curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
    echo "                   nvm install --lts"
    echo ""
    exit 1
fi
echo " [OK] Node.js: $(node --version)  npm: $(npm --version)"

# Install dependencies
echo ""
echo " Installing dependencies..."
npm install
echo " [OK] Dependencies installed."

# Create uploads directory
mkdir -p uploads
echo " [OK] uploads/ directory ready."

# Copy .env.example to .env if not present
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo " [OK] Created .env from template."
    echo ""
    echo " *** ACTION REQUIRED ***"
    echo " Edit .env and fill in:"
    echo "   SERVER_URL   - your machine's local IP (run: ip a | grep inet)"
    echo "   SERVER_SECRET - any random string (must match lib/config.dart)"
    echo "   AI_PROVIDER  - groq (free) or another provider"
    echo "   GROQ_API_KEY - get from console.groq.com (free)"
    echo "   FIREBASE_SERVICE_ACCOUNT_PATH - path to your Firebase service account JSON"
    echo ""
    echo " Also copy your Firebase service account JSON to this folder."
    echo " Download from: Firebase Console > Project Settings > Service Accounts"
    echo ""
else
    echo " [OK] .env already exists (not overwritten)."
fi

# Make start.sh executable
chmod +x start.sh
echo " [OK] start.sh is now executable."

echo ""
echo " Setup complete. Run ./start.sh to launch the server."
echo ""
