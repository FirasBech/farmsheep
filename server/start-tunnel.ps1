# start-tunnel.ps1
# Starts the Node server + Cloudflare tunnel, then auto-updates lib/config.dart
# Run from the farmsheep root or server/ directory.
# Usage:  powershell -ExecutionPolicy Bypass -File server\start-tunnel.ps1

$ErrorActionPreference = 'Stop'

$root      = Split-Path $PSScriptRoot -Parent
$serverDir = $PSScriptRoot
$configDart = Join-Path $root 'lib\config.dart'
$secret    = 'farmsheep-local-test'
$port      = 3001
$logFile   = Join-Path $env:TEMP 'cloudflared_farmsheep.log'

Write-Host ""
Write-Host "=== FarmSheep Server + Tunnel ===" -ForegroundColor Cyan

# ── 1. Start Node server ──────────────────────────────────────────────────────
$serverRunning = $false
try {
    $resp = Invoke-WebRequest -Uri "http://localhost:$port/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
    if ($resp.StatusCode -eq 200) { $serverRunning = $true }
} catch {}

if ($serverRunning) {
    Write-Host "[Server] Already running on port $port" -ForegroundColor Green
} else {
    Write-Host "[Server] Starting Node server..." -ForegroundColor Yellow
    $serverProc = Start-Process -FilePath "node" `
        -ArgumentList "index.js" `
        -WorkingDirectory $serverDir `
        -WindowStyle Hidden `
        -PassThru
    # Wait up to 8 seconds for it to be ready
    $ready = $false
    for ($i = 0; $i -lt 16; $i++) {
        Start-Sleep -Milliseconds 500
        try {
            $r = Invoke-WebRequest -Uri "http://localhost:$port/health" -UseBasicParsing -TimeoutSec 1 -ErrorAction Stop
            if ($r.StatusCode -eq 200) { $ready = $true; break }
        } catch {}
    }
    if ($ready) {
        Write-Host "[Server] Ready on port $port" -ForegroundColor Green
    } else {
        Write-Host "[Server] WARN: server did not respond in 8s — check your .env" -ForegroundColor Red
    }
}

# ── 2. Start Cloudflare tunnel ────────────────────────────────────────────────
Write-Host "[Tunnel] Starting Cloudflare tunnel..." -ForegroundColor Yellow
if (Test-Path $logFile) { Remove-Item $logFile -Force }

# Prefer local cloudflared.exe in server/ folder, fall back to system PATH
$cfExe = Join-Path $serverDir 'cloudflared.exe'
if (-not (Test-Path $cfExe)) { $cfExe = 'cloudflared' }

$tunnelProc = Start-Process -FilePath $cfExe `
    -ArgumentList "tunnel", "--url", "http://localhost:$port" `
    -RedirectStandardError $logFile `
    -WindowStyle Hidden `
    -PassThru

# ── 3. Wait for URL to appear in log ─────────────────────────────────────────
Write-Host "[Tunnel] Waiting for URL (up to 30s)..." -ForegroundColor Yellow
$tunnelUrl = $null
for ($i = 0; $i -lt 60; $i++) {
    Start-Sleep -Milliseconds 500
    if (Test-Path $logFile) {
        $content = Get-Content $logFile -Raw -ErrorAction SilentlyContinue
        if ($content -match 'https://[a-z0-9\-]+\.trycloudflare\.com') {
            $tunnelUrl = $Matches[0]
            break
        }
    }
}

if (-not $tunnelUrl) {
    Write-Host "[Tunnel] ERROR: Could not read tunnel URL. Log:" -ForegroundColor Red
    if (Test-Path $logFile) { Get-Content $logFile | Select-Object -Last 20 }
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit 1
}

Write-Host "[Tunnel] URL: $tunnelUrl" -ForegroundColor Green

# ── 4. Update lib/config.dart (fallback) ─────────────────────────────────────
$dartContent = @"
// Fallback used before Firestore config is loaded. Overwritten at startup.
String kServerUrl = '$tunnelUrl';
const String kServerSecret = '$secret';
"@
Set-Content -Path $configDart -Value $dartContent -Encoding UTF8
Write-Host "[Config] lib/config.dart updated" -ForegroundColor Green

# ── 5. Write URL to Firestore so app picks it up without a rebuild ────────────
Write-Host "[Firestore] Writing tunnel URL to /config/server..." -ForegroundColor Yellow
$updateResult = node -e @"
const admin = require('firebase-admin');
const sa = require('./$((Get-ChildItem $serverDir -Filter '*firebase-adminsdk*.json' | Select-Object -First 1).Name)');
admin.initializeApp({ credential: admin.credential.cert(sa) });
admin.firestore().collection('config').doc('server')
  .set({ url: '$tunnelUrl', updatedAt: new Date().toISOString() })
  .then(() => { console.log('ok'); process.exit(0); })
  .catch(e => { console.error(e.message); process.exit(1); });
"@ 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[Firestore] Done — app will use new URL on next launch (no rebuild needed)" -ForegroundColor Green
} else {
    Write-Host "[Firestore] WARN: could not update Firestore: $updateResult" -ForegroundColor Red
    Write-Host "[Firestore] App will use the config.dart fallback URL" -ForegroundColor DarkGray
}

# ── 5. Done ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host " Server  : http://localhost:$port"      -ForegroundColor White
Write-Host " Tunnel  : $tunnelUrl"                  -ForegroundColor White
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next: press R (hot restart) in your flutter run terminal." -ForegroundColor Yellow
Write-Host "Keep this window open — closing it kills the tunnel." -ForegroundColor DarkGray
Write-Host ""
Write-Host "Press Ctrl+C to stop everything." -ForegroundColor DarkGray

# Keep running so the tunnel stays alive
try {
    Wait-Process -Id $tunnelProc.Id
} catch {
    # Tunnel exited or Ctrl+C
}
Write-Host "Tunnel stopped."
