#!/bin/bash

# Installer Flutter (si pas déjà installé)
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Vérifier que Flutter est bien installé
flutter doctor

# Compiler l'application Flutter pour le Web
flutter build web

# Installer les dépendances Node.js
npm install
