enum AppUserRole { player, admin }

class AdminAccess {
  static final Set<String> _adminEmails = _buildAdminEmails();

  static bool isAdminEmail(String? email) {
    if (email == null) return false;
    return _adminEmails.contains(email.trim().toLowerCase());
  }

  static Set<String> _buildAdminEmails() {
    const explicitAdmins = <String>{
      '211wita26@o365.htl-leoben.at',
    };

    const teacherNames = <String>[
      'Helmut Antrekowitsch',
      'Klaus Auracher',
      'Eduard Baeck',
      'Thomas Beidl',
      'Petra Berghold',
      'Idriz Cikaric',
      'Elisabeth Dovalil',
      'Astrid Edler',
      'Maximilian Ederegger',
      'Manuel Fink',
      'Carmen Gass',
      'Olivia Glanzer',
      'Alexandra Gmundtner',
      'Susanne Goelz',
      'Klaus Haberz',
      'Anna-Maria Hatzl',
      'Robert Hermann',
      'Beatrix Hochoertler',
      'Christian Hofer',
      'Guenther Hutter',
      'Darko Jankovic',
      'Georg Judmaier',
      'Christina Kainz',
      'Michaela Kammleitner',
      'Klaus Kepplinger',
      'Hubert Kerber',
      'Uwe Kondert',
      'Joerg Korp',
      'Johannes Kuchler',
      'Cora Kumnig',
      'Ramona Langer',
      'Nina Laschan',
      'Christoph Leitner',
      'Daniel Lenz',
      'Tobias Loibner',
      'Stefan Lorbek',
      'Anja Lube',
      'Annika Mayr',
      'Thomas Messner',
      'Thomas Moffat',
      'Alexander Moser-Tscharf',
      'Lisa Nowak',
      'Anne Nylander',
      'Elisabeth Ofner',
      'Thomas Pollak',
      'Isabelle Prenn',
      'Gudrun Reisenhofer',
      'Samir Reiter',
      'Christian Schindler',
      'Rene Schuster',
      'Robert Schueller',
      'Tamara Schweiger',
      'Helmut Steineder',
      'Christian Steiner',
      'Sebastian Steiner',
      'Stefan Stockinger',
      'Clemens Suppan',
      'Andreas Weichbold',
      'Michael Weinhandl',
      'Christian Wibner',
      'Stefan Wibner',
      'Peter Wilding',
      'Barbara Wohlmuth',
      'Markus Zacharias',
    ];

    final emails = <String>{...explicitAdmins};
    for (final name in teacherNames) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length < 2) continue;

      final first = _normalizeEmailPart(parts.first);
      final last = _normalizeEmailPart(parts.last);
      if (first.isEmpty || last.isEmpty) continue;

      emails.add('$first.$last@htl-leoben.at');
      emails.add('${first.replaceAll('-', '')}.$last@htl-leoben.at');
      emails.add('$first.${last.replaceAll('-', '')}@htl-leoben.at');
      emails.add(
        '${first.replaceAll('-', '')}.${last.replaceAll('-', '')}@htl-leoben.at',
      );
    }
    return emails;
  }

  static String _normalizeEmailPart(String value) {
    final lower = value.toLowerCase();
    return lower
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '');
  }
}
