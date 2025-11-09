# 🚨 Module SOS - Fonctionnalités d'Urgence

Ce dossier contient tous les composants liés aux fonctionnalités d'urgence de l'application.

## 📁 Structure du dossier

```
lib/sos/
├── sos.dart                    # Fichier d'export principal
├── emergency_service.dart      # Service de gestion des alertes d'urgence
├── emergency_contacts_page.dart # Page de gestion des contacts d'urgence
├── database_seeder.dart        # Script de remplissage de la base de données
├── database_viewer_page.dart   # Page de visualisation des données
└── README.md                   # Ce fichier
```

## 🔧 Composants

### 1. **EmergencyService** (`emergency_service.dart`)
Service principal pour gérer les alertes d'urgence :
- Géolocalisation automatique
- Envoi d'alertes d'urgence
- Gestion des contacts d'urgence
- Appels automatiques
- Historique des alertes

### 2. **EmergencyContactsPage** (`emergency_contacts_page.dart`)
Interface utilisateur pour gérer les contacts d'urgence :
- Ajout de nouveaux contacts
- Modification des contacts existants
- Suppression de contacts
- Gestion des priorités
- Interface moderne et intuitive

### 3. **DatabaseSeeder** (`database_seeder.dart`)
Script pour remplir automatiquement la base de données avec des données d'exemple :
- Contacts d'urgence prédéfinis
- Guides de premiers secours
- Dossier médical d'exemple
- Médicaments d'exemple

### 4. **DatabaseViewerPage** (`database_viewer_page.dart`)
Page de visualisation et de gestion de la base de données :
- Affichage de toutes les tables
- Statistiques des données
- Possibilité de vider et re-remplir la base
- Détails des enregistrements

### 5. **sos.dart** (Fichier d'export)
Fichier d'index qui exporte tous les composants du module SOS pour faciliter les imports.

## 🚀 Utilisation

### Import simple
```dart
import '../sos/sos.dart';
```

### Import spécifique
```dart
import '../sos/emergency_service.dart';
import '../sos/emergency_contacts_page.dart';
```

## 🔗 Intégration

Ce module est intégré dans :
- `lib/com/articles_display.dart` - Bouton SOS dans la barre de navigation
- Base de données - Tables d'urgence (EmergencyAlert, EmergencyContact, etc.)

## 📱 Fonctionnalités

- ✅ Bouton SOS dans la barre de navigation
- ✅ Géolocalisation automatique
- ✅ Envoi d'alertes d'urgence
- ✅ Gestion des contacts d'urgence
- ✅ Appels automatiques
- ✅ Interface utilisateur moderne
- ✅ Intégration base de données
- ✅ Remplissage automatique de données d'exemple
- ✅ Visualisation des données de la base
- ✅ Guides de premiers secours
- ✅ Dossier médical utilisateur
- ✅ Gestion des médicaments

## 🛠️ Dépendances

- `geolocator` - Géolocalisation
- `permission_handler` - Gestion des permissions
- `url_launcher` - Appels téléphoniques
- Base de données SQLite locale

---

**Module SOS prêt à l'emploi ! 🚨**
