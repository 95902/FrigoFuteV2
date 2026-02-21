/// Status de synchronisation entre local (Hive) et cloud (Firestore)
enum SyncStatus {
  /// Toutes les données sont synchronisées
  synced,

  /// Synchronisation en cours
  syncing,

  /// Mode offline (pas de connexion réseau)
  offline,

  /// Erreur de synchronisation
  error,
}
