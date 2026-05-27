#!/usr/bin/env bash
set -e

echo ""
echo " Starting FarmSheep Server..."
echo " Press Ctrl+C to stop."
echo ""

if [ ! -f ".env" ]; then
    echo " [ERROR] .env not found. Run ./setup.sh first."
    exit 1
fi

if [ ! -d "node_modules" ]; then
    echo " [ERROR] node_modules not found. Run ./setup.sh first."
    exit 1
fi

node index.js
