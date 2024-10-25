// firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> toggleBookmark(String userId, int movieId) async {
    final userDoc = _firestore.collection('users').doc(userId);
    final snapshot = await userDoc.get();

    List<dynamic> bookmarks = snapshot.data()?['movie_bookmark'] ?? [];

    if (bookmarks.contains(movieId)) {
      await userDoc.update({
        'movie_bookmark': FieldValue.arrayRemove([movieId])
      });
    } else {
      await userDoc.update({
        'movie_bookmark': FieldValue.arrayUnion([movieId])
      });
    }
  }

  Future<void> toggleWatched(String userId, int movieId) async {
    final userDoc = _firestore.collection('users').doc(userId);
    final snapshot = await userDoc.get();

    List<dynamic> watched = snapshot.data()?['movie_watched'] ?? [];

    if (watched.contains(movieId)) {
      await userDoc.update({
        'movie_watched': FieldValue.arrayRemove([movieId])
      });
    } else {
      await userDoc.update({
        'movie_watched': FieldValue.arrayUnion([movieId])
      });
    }
  }

  Future<bool> isBookmarked(String userId, int movieId) async {
    final snapshot = await _firestore.collection('users').doc(userId).get();
    List<dynamic> bookmarks = snapshot.data()?['movie_bookmark'] ?? [];
    return bookmarks.contains(movieId);
  }

  Future<bool> isWatched(String userId, int movieId) async {
    final snapshot = await _firestore.collection('users').doc(userId).get();
    List<dynamic> watched = snapshot.data()?['movie_watched'] ?? [];
    return watched.contains(movieId);
  }
}
