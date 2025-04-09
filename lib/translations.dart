String translated(String key, String language) {
  const translations = {
    'select_user': {
      'en': 'Select User',
      'fi': 'Valitse käyttäjä',
      'sv': 'Välj användare',
    },
    'create_new_user': {
      'en': 'Create New User',
      'fi': 'Luo uusi käyttäjä',
      'sv': 'Skapa ny användare',
    },
    'new_training_session': {
      'en': 'New Training Session',
      'fi': 'Uusi harjoituskerta',
      'sv': 'Ny träningssession',
    },
    'edit_profile': {
      'en': 'Edit Profile',
      'fi': 'Muokkaa profiilia',
      'sv': 'Redigera profil',
    },
    'view_session_history': {
      'en': 'View Session History',
      'fi': 'Näytä sessiohistoria',
      'sv': 'Visa sessionshistorik',
    },
    'manage_sites_targets': {
      'en': 'Manage Sites & Targets',
      'fi': 'Hallinnoi mittauspaikkoja',
      'sv': 'Hantera platser och mål',
    },
    'export_csv': {
      'en': 'Export Data to CSV',
      'fi': 'Vie tiedot CSV-muotoon',
      'sv': 'Exportera data till CSV',
    },
    'switch_user': {
      'en': 'Switch User',
      'fi': 'Vaihda käyttäjää',
      'sv': 'Byt användare',
    },
    'add_site': {
      'en': 'Add Site',
      'fi': 'Lisää mittauspaikka',
      'sv': 'Lägg till plats',
    },
    'add_target': {
      'en': 'Add Target',
      'fi': 'Lisää maali',
      'sv': 'Lägg till mål',
    },
    'finish_session': {
      'en': 'Finish Session',
      'fi': 'Lopeta sessio',
      'sv': 'Avsluta session',
    },
  };

  return translations[key]?[language] ?? key;
}
