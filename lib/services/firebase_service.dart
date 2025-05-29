import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all tickets
  static Stream<List<Ticket>> getTickets() {
    return _firestore
        .collection('tickets')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ticket.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get single ticket
  static Future<Ticket?> getTicket(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('tickets').doc(id).get();
      if (doc.exists) {
        return Ticket.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting ticket: $e');
      return null;
    }
  }

  // Add purchase
  static Future<String?> addPurchase(Purchase purchase) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('purchases')
          .add(purchase.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding purchase: $e');
      return null;
    }
  }

  // Get purchase by ID
  static Future<Purchase?> getPurchase(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('purchases').doc(id).get();
      if (doc.exists) {
        return Purchase.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting purchase: $e');
      return null;
    }
  }
}