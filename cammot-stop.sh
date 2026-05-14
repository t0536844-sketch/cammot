#!/data/data/com.termux/files/usr/bin/bash
# cammot-stop.sh — Stop CAMMOT server + Cloudflare Tunnel

echo "🛑 Menghentikan CAMMOT..."

PIDFILE="$HOME/.cammot.pid"
if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null && echo "  Server dihentikan"
    rm -f "$PIDFILE"
fi

pkill -f "cloudflared.*tunnel.*3000" 2>/dev/null && echo "  Tunnel dihentikan"
pkill -f "node.*cammot.*server" 2>/dev/null

echo "✅ CAMMOT dihentikan"
