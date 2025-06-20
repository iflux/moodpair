#!/bin/bash
# Installe Flutter dans le dossier courant
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Vérifie que Flutter est installé correctement
flutter doctor

# Récupère les dépendances de Flutter
flutter pub get

# Compile l'application Flutter pour le Web
flutter build web
