#!/data/data/com.termux/files/usr/bin/bash
# cammot-start.sh — Start CAMMOT server + Cloudflare Tunnel
# Usage: ./cammot-start.sh

set -e

CAPP_DIR="$HOME/cammot"
PIDFILE="$HOME/.cammot.pid"
TUNNEL_LOG="$HOME/.cammot_tunnel.log"

# Kill existing processes
echo "🛑 Mengecek proses sebelumnya..."
if [ -f "$PIDFILE" ]; then
    OLD_PID=$(cat "$PIDFILE")
    kill "$OLD_PID" 2>/dev/null && echo "  Server lama (PID $OLD_PID) dihentikan"
    rm -f "$PIDFILE"
fi

# Kill existing cloudflared
pkill -f "cloudflared.*tunnel.*3000" 2>/dev/null && echo "  Tunnel lama dihentikan"

# Clean up
rm -f "$TUNNEL_LOG"

# Start Node.js server
echo "🚀 Memulai CAMMOT server..."
cd "$CAPP_DIR"
node server.js &
SERVER_PID=$!
echo "$SERVER_PID" > "$PIDFILE"
echo "  Server berjalan (PID $SERVER_PID) di http://localhost:3000"

# Wait for server
echo "⏳ Menunggu server siap..."
for i in $(seq 1 10); do
    if curl -s -o /dev/null http://localhost:3000 2>/dev/null; then
        echo "  ✅ Server siap!"
        break
    fi
    sleep 1
done

# Start Cloudflare Tunnel
echo "🌐 Membuat Cloudflare Tunnel..."
cloudflared tunnel --url http://localhost:3000 --no-autoupdate --protocol quic 2>&1 | tee "$TUNNEL_LOG" &

# Wait for tunnel URL
echo "⏳ Menunggu tunnel aktif..."
for i in $(seq 1 20); do
    if [ -f "$TUNNEL_LOG" ]; then
        URL=$(grep -oP 'https://[a-zA-Z0-9-]+\.trycloudflare\.com' "$TUNNEL_LOG" 2>/dev/null | head -1)
        if [ -n "$URL" ]; then
            echo ""
            echo "============================================"
            echo "  ✅ CAMMOT ONLINE!"
            echo "  URL: $URL"
            echo "============================================"
            echo ""
            exit 0
        fi
    fi
    sleep 1
done

echo "⚠️  Timeout menunggu tunnel. Cek $TUNNEL_LOG"
