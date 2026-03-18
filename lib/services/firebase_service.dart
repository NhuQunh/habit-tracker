import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_tracker/models/habit.dart';

class FirebaseService {
  FirebaseService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _habitsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('habits');
  }

  Stream<List<Habit>> watchHabits(String userId) {
    return _habitsCollection(userId)
        .orderBy('createdAt', descending: false)
        .snapshots(includeMetadataChanges: true)
        .map(
          (snapshot) => snapshot.docs
              .map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return Habit.fromJson(data);
              })
              .toList(),
        );
  }

  Future<List<Habit>> getHabits(String userId) async {
    final snapshot = await _habitsCollection(userId)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Habit.fromJson(data);
        })
        .toList();
  }

  Future<List<Habit>> getHabitsWithLocalFallback(
    String userId,
    List<Habit> localHabits,
  ) async {
    try {
      final snapshot = await _habitsCollection(userId)
          .orderBy('createdAt', descending: false)
          .get(const GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isEmpty) {
        return localHabits;
      }

      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Habit.fromJson(data);
          })
          .toList();
    } catch (_) {
      return localHabits;
    }
  }

  Future<void> setHabits(String userId, List<Habit> habits) async {
    final batch = _firestore.batch();
    final collection = _habitsCollection(userId);

    final existingSnapshot = await collection.get();
    final targetIds = habits.map((habit) => habit.id).toSet();

    for (final doc in existingSnapshot.docs) {
      if (!targetIds.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }

    for (final habit in habits) {
      final docRef = collection.doc(habit.id);
      final data = habit.toJson();
      data.remove('id');
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['createdAt'] ??= FieldValue.serverTimestamp();
      batch.set(docRef, data, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> upsertHabit(String userId, Habit habit) async {
    final data = habit.toJson();
    data.remove('id');
    data['updatedAt'] = FieldValue.serverTimestamp();
    data['createdAt'] ??= FieldValue.serverTimestamp();

    await _habitsCollection(userId).doc(habit.id).set(
      data,
      SetOptions(merge: true),
    );
  }

  Future<void> deleteHabit(String userId, String habitId) async {
    await _habitsCollection(userId).doc(habitId).delete();
  }
}