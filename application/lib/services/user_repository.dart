import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Future<bool> isUsernameTaken(String usernameLower) async {
    final snap = await _db
        .collection('Users')
        .where('UsernameLower', isEqualTo: usernameLower)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<String?> emailForUsername(String usernameLower) async {
    final snap = await _db
        .collection('Users')
        .where('UsernameLower', isEqualTo: usernameLower)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final email = snap.docs.first.data()['Email'] as String?;
    if (email == null || email.trim().isEmpty) return null;
    return email.trim().toLowerCase();
  }

  Future<void> upsertBasicProfile(
    String uid, {
    required String username,
    required String email,
  }) {
    return _db.collection('Users').doc(uid).set(
      {
        'Username': username,
        'UsernameLower': username.toLowerCase(),
        'Email': email.toLowerCase(),
      },
      SetOptions(merge: true),
    );
  }
}
