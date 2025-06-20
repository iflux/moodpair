const express = require('express');
const path = require('path');

const app = express();

// Définir le répertoire où Flutter a généré les fichiers Web (ici, 'web/')
const webDir = path.join(__dirname, '..', 'web'); // Répertoire web à la racine de ton projet

// Servir les fichiers statiques depuis le répertoire 'web/'
app.use(express.static(webDir));

// Route de fallback pour toutes les autres pages (si nécessaire)
app.get('*', (req, res) => {
  res.sendFile(path.join(webDir, 'index.html')); // Sert index.html pour toute autre route
});

// Lancer le serveur sur un port dynamique ou 3000
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Serveur Express en écoute sur le port ${port}`);
});
