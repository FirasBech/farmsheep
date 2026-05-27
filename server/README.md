# FarmSheep Server

Self-hosted backend that replaces Firebase Storage and Cloud Functions.
Runs on your Linux machine — the Flutter app talks to it over your home network.

## What it does

| Endpoint | Purpose |
| --- | --- |
| `POST /api/photo/upload` | Upload animal photos (saved in `uploads/`) |
| `DELETE /api/photo` | Delete a photo by URL |
| `POST /api/ai` | AI features proxy (health chat, breed recommendations, etc.) |
| `POST /api/partner` | Create partner accounts (needs Firebase Admin) |
| `POST /api/farm/delete-cascade` | Delete a farm and all its data |
| `GET /uploads/:filename` | Serve stored photos |
| `GET /health` | Server health check |

## Setup (3 steps)

### Step 1 — Install Node.js

```bash
# Ubuntu / Debian / Kali
sudo apt update && sudo apt install -y nodejs npm

# Or use nvm (recommended — gets the latest LTS):
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install --lts
```

### Step 2 — First-time setup

```bash
chmod +x setup.sh
./setup.sh
```

This will: install dependencies, create the `uploads/` folder, and copy `.env.example` → `.env`.

### Step 3 — Configure `.env`

```bash
nano .env   # or: vim .env
```

Fill in:

```env
SERVER_URL=http://YOUR_IP:3000    # find your IP: ip a | grep "inet "
SERVER_SECRET=any-random-string   # must match kServerSecret in lib/config.dart
AI_PROVIDER=groq
GROQ_API_KEY=gsk_...              # free at console.groq.com
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
```

Also **copy your Firebase service account JSON** to this folder:

- Firebase Console → Project Settings → Service Accounts → Generate new private key
- Save the downloaded file as `firebase-service-account.json` in this folder

### Running the server

```bash
./start.sh
```

Keep it running while using the app. To run it in the background:

```bash
nohup ./start.sh &> server.log &
# stop it later with: kill $(lsof -t -i:3000)
```

### Auto-start on boot (optional)

```bash
sudo nano /etc/systemd/system/farmsheep.service
```

Paste:

```ini
[Unit]
Description=FarmSheep Server
After=network.target

[Service]
WorkingDirectory=/path/to/server
ExecStart=/usr/bin/node index.js
Restart=always
EnvironmentFile=/path/to/server/.env

[Install]
WantedBy=multi-user.target
```

Then:

```bash
sudo systemctl enable farmsheep
sudo systemctl start farmsheep
```

## Flutter app config

In `lib/config.dart`:

```dart
const String kServerUrl = 'http://YOUR_IP:3000';
const String kServerSecret = 'same-value-as-SERVER_SECRET-in-env';
```

Rebuild and install the app after changing these.

## Notes

- **Photos** are stored in `uploads/`. Back it up if you want to keep animal photos.
- **AI rate limit**: 20 requests per user per hour (resets if server restarts).
- **Firebase Admin** is only needed for `createPartner` and `deleteFarmCascade`. Photo upload and AI work without it.
- The server binds to `0.0.0.0` so it's reachable from other devices on the network.
- If the phone can't reach the server, check your firewall: `sudo ufw allow 3000`.
