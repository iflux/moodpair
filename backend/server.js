const express = require('express');
const { Server } = require('socket.io');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

// Servez les fichiers statiques de l'application Flutter
app.use(express.static(path.join(__dirname, 'build', 'web')));

// Créez un serveur WebSocket avec Socket.IO
const io = new Server(app.listen(port, () => {
  console.log(`🚀 Serveur WebSocket et HTTP en ligne sur le port ${port}`);
}), {
  cors: { origin: '*' }
});

let partners = {}; // socketId -> partnerId
let feedbacks = [];
let reports = [];
let reportCount = {}; // socketId -> count
let banned = new Set();

// Configuration WebSocket
io.on('connection', (socket) => {
  console.log('✅ Client connecté :', socket.id);

  if (banned.has(socket.id)) {
    console.log(`⛔ Accès refusé à ${socket.id} (banni)`);
    socket.disconnect(true);
    return;
  }

  socket.emit('feedback_update', feedbacks);
  socket.emit('report_update', reports);

  socket.on('join', (mood) => {
    console.log(`🧠 ${socket.id} cherche un pair avec l'humeur "${mood}"`);

    waitingQueue = waitingQueue.filter(entry => entry.socketId !== socket.id);

    const match = waitingQueue.find(entry => entry.mood === mood);
    if (match) {
      const partnerSocket = io.sockets.sockets.get(match.socketId);
      if (partnerSocket) {
        partners[socket.id] = match.socketId;
        partners[match.socketId] = socket.id;

        socket.emit('matched', match.socketId);
        partnerSocket.emit('matched', socket.id);

        console.log(`🤝 Match entre ${socket.id} et ${match.socketId}`);
      }
      waitingQueue = waitingQueue.filter(entry => entry.socketId !== match.socketId);
    } else {
      waitingQueue.push({ socketId: socket.id, mood });
      console.log(`👤 Ajouté à la file : ${socket.id}`);
    }
  });

  // Gérer d'autres événements comme 'left', 'feedback', 'message', etc.
  // ...

  socket.on('disconnect', () => {
    console.log(`❌ ${socket.id} s'est déconnecté`);
    // Gérer la déconnexion des utilisateurs
  });
});

// Route HTTP pour la page d'accueil ou d'autres pages Flutter
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'web', 'index.html'));
});

console.log('🚀 Serveur HTTP et WebSocket prêt');
