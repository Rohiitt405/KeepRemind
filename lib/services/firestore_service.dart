import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reel_item.dart';

class FirestoreService {
  // Single instances of Firebase services
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in anonymously and return the user's unique ID
  Future<String> getOrCreateUserId() async {
    // If already signed in, return existing user ID
    if (_auth.currentUser != null) {
      return _auth.currentUser!.uid;
    }
    // Otherwise sign in anonymously
    final result = await _auth.signInAnonymously();
    return result.user!.uid;
  }

  // Get a reference to this user's reels collection in Firestore
  // Path: users/{userId}/reels
  Future<CollectionReference> _reelsCollection() async {
    final userId = await getOrCreateUserId();
    return _db.collection('users').doc(userId).collection('reels');
  }

  // Save a new reel to Firestore
  Future<String> saveReel(ReelItem reel) async {
    final collection = await _reelsCollection();
    // .add() auto-generates a unique document ID
    final docRef = await collection.add(reel.toMap());
    return docRef.id;
  }

  // Fetch all reels as a live stream (UI updates automatically)
  Stream<List<ReelItem>> getReels() async* {
    final collection = await _reelsCollection();
    // snapshots() emits a new list every time Firestore data changes
    yield* collection
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReelItem.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Update a reel document with partial fields
  Future<void> updateReel(String reelId, Map<String, dynamic> data) async {
    final collection = await _reelsCollection();
    await collection.doc(reelId).update(data);
  }

  // Mark a reel as reviewed
  Future<void> markAsReviewed(String reelId) async {
    final collection = await _reelsCollection();
    await collection.doc(reelId).update({'isReviewed': true});
  }

  // Delete a reel
  Future<void> deleteReel(String reelId) async {
    final collection = await _reelsCollection();
    await collection.doc(reelId).delete();
  }
}