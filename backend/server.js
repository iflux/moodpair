const { Server } = require('socket.io');
const io = new Server(3000, {
  cors: { origin: '*' }
});

let waitingQueue = [];
let partners = {}; // socketId -> partnerId
let feedbacks = [];
let reports = [];
let reportCount = {}; // socketId -> count
let banned = new Set();

io.on('connection', (socket) => {
  console.log('✅ Client connecté :', socket.id);

  // Refuser l'accès aux bannis
  if (banned.has(socket.id)) {
    console.log(`⛔ Accès refusé à ${socket.id} (banni)`);
    socket.disconnect(true);
    return;
  }

  // Envoyer l'état initial au dashboard admin
  socket.emit('feedback_update', feedbacks);
  socket.emit('report_update', reports);

  socket.on('join', (mood) => {
    console.log(`🧠 ${socket.id} cherche un pair avec l'humeur "${mood}"`);

    if (reportCount[socket.id] >= 3) {
      console.log(`🚩 ${socket.id} est marqué comme redflag`);
    }

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

  socket.on('left', () => {
    console.log(`⬅️ ${socket.id} a quitté la session`);
    const partnerId = partners[socket.id];
    if (partnerId && io.sockets.sockets.has(partnerId)) {
      io.to(partnerId).emit('disconnect_notice', { from: socket.id });
    }
    delete partners[partnerId];
    delete partners[socket.id];
    waitingQueue = waitingQueue.filter(entry => entry.socketId !== socket.id);
  });

  socket.on('feedback', (data) => {
    const entry = { ...data, timestamp: new Date().toISOString() };
    feedbacks.unshift(entry);
    io.emit('feedback_update', feedbacks);
    console.log(`📝 Avis reçu : ${data.mood} - ${data.choice}`);
  });

  socket.on('report', (data) => {
    const entry = {
      partnerId: data.partnerId,
      reason: data.reason,
      mood: data.mood,
      timestamp: new Date().toISOString(),
    };
    reports.unshift(entry);
    io.emit('report_update', reports);
    reportCount[data.partnerId] = (reportCount[data.partnerId] || 0) + 1;

    const partnerSocket = io.sockets.sockets.get(data.partnerId);
    if (partnerSocket) {
      partnerSocket.emit('reported_notice');
      partnerSocket.emit('disconnect_notice', { from: 'admin_report' });
      partnerSocket.disconnect(true);
    }

    if (reportCount[data.partnerId] >= 3) {
      banned.add(data.partnerId);
    }

    console.log(`🚨 Signalement reçu contre ${data.partnerId} (${reportCount[data.partnerId]} fois)`);
  });

  socket.on('message', (data) => {
    const partnerId = partners[socket.id];
    if (partnerId && io.sockets.sockets.has(partnerId)) {
      io.to(partnerId).emit('message', data);
    }
  });

  socket.on('clear_feedbacks', (pwd) => {
    if (pwd === 'admin123') {
      feedbacks = [];
      io.emit('feedback_update', feedbacks);
      console.log('🧹 Feedbacks vidés par l\'admin');
    }
  });

  socket.on('clear_reports', (pwd) => {
    if (pwd === 'admin123') {
      reports = [];
      reportCount = {};
      banned.clear();
      io.emit('report_update', reports);
      console.log('🧼 Signalements vidés par l\'admin');
    }
  });

  socket.on('disconnect', () => {
    console.log(`❌ ${socket.id} s'est déconnecté`);
    const partnerId = partners[socket.id];
    if (partnerId && io.sockets.sockets.has(partnerId)) {
      io.to(partnerId).emit('disconnect_notice', { from: socket.id });
    }
    delete partners[partnerId];
    delete partners[socket.id];
    waitingQueue = waitingQueue.filter(entry => entry.socketId !== socket.id);
  });
});

console.log('🚀 Serveur WebSocket en ligne : http://localhost:3000');
