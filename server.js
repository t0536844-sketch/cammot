const express = require('express');
const app = express();
const http = require('http').createServer(app);
const io = require('socket.io')(http, {
  cors: {
    origin: "*",          // Untuk testing, boleh diubah ke domain spesifik nanti
    methods: ["GET", "POST"]
  }
});

// Serve file statis dari folder public
app.use(express.static('public'));

// Route utama: kirim index.html
app.get('/', (req, res) => {
  res.sendFile(__dirname + '/public/index.html');
});

// Object untuk simpan broadcaster (sementara hanya support 1 broadcaster)
let broadcasterSocket = null;

io.on('connection', (socket) => {
  console.log(`Client connect: ${socket.id}`);

  // Client register role-nya
  socket.on('register', (role) => {
    if (role === 'broadcaster') {
      if (broadcasterSocket) {
        socket.emit('error', 'Sudah ada broadcaster aktif. Hanya 1 broadcaster yang diizinkan.');
        socket.disconnect();
        return;
      }
      broadcasterSocket = socket;
      console.log(`Broadcaster terdaftar: ${socket.id}`);
      socket.emit('registered', 'broadcaster');
      // Beritahu semua viewer bahwa broadcaster sudah siap
      socket.broadcast.emit('broadcaster-ready');
    } else {
      console.log(`Viewer terdaftar: ${socket.id}`);
      socket.emit('registered', 'viewer');
      // Jika broadcaster sudah ada, beri tahu viewer
      if (broadcasterSocket) {
        socket.emit('broadcaster-ready');
      }
    }
  });

  // Signaling: offer (dari viewer ke broadcaster)
  socket.on('offer', (data) => {
    console.log(`Offer diterima dari ${socket.id}`);
    if (broadcasterSocket && broadcasterSocket !== socket) {
      broadcasterSocket.emit('offer', data);
    } else {
      socket.emit('error', 'Tidak ada broadcaster aktif');
    }
  });

  // Signaling: answer (dari broadcaster ke viewer)
  socket.on('answer', (data) => {
    console.log(`Answer diterima dari ${socket.id}`);
    socket.broadcast.emit('answer', data);  // Kirim ke semua (viewer yang butuh)
  });

  // Signaling: ICE candidate (dari siapa saja)
  socket.on('candidate', (data) => {
    console.log(`Candidate diterima dari ${socket.id}`);
    socket.broadcast.emit('candidate', data);
  });

  // Handle disconnect
  socket.on('disconnect', () => {
    console.log(`Client disconnect: ${socket.id}`);
    if (socket === broadcasterSocket) {
      console.log('Broadcaster disconnect → reset');
      broadcasterSocket = null;
      io.emit('broadcaster-disconnected');
    }
  });

  // Optional: error handling
  socket.on('error', (err) => {
    console.error('Socket error:', err);
  });
});

// Jalankan server
const PORT = process.env.PORT || 3000;
http.listen(PORT, () => {
  console.log(`Server berjalan di http://localhost:${PORT}`);
  console.log('Akses dari browser: http://localhost:3000');
  console.log('Atau gunakan IP perangkat kamu (contoh: http://192.168.1.100:3000)');
});
