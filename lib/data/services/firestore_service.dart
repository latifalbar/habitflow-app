import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firestore service for cloud data operations (Premium users only)
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Get current user ID
  String? get _userId => _auth.currentUser?.uid;
  
  /// Check if user is authenticated
  bool get _isAuthenticated => _auth.currentUser != null;
  
  /// Get user document reference
  DocumentReference get _userDoc {
    if (!_isAuthenticated || _userId == null) {
      throw Exception('User must be authenticated to access Firestore');
    }
    return _firestore.collection('users').doc(_userId);
  }
  
  /// Get subcollection reference
  CollectionReference _getSubcollection(String subcollection) {
    return _userDoc.collection(subcollection);
  }
  
  /// Create document
  Future<void> createDocument({
    required String subcollection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    if (!_isAuthenticated) return;
    
    try {
      await _getSubcollection(subcollection).doc(documentId).set(data);
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }
  
  /// Read document
  Future<Map<String, dynamic>?> readDocument({
    required String subcollection,
    required String documentId,
  }) async {
    if (!_isAuthenticated) return null;
    
    try {
      final doc = await _getSubcollection(subcollection).doc(documentId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      throw Exception('Failed to read document: $e');
    }
  }
  
  /// Update document
  Future<void> updateDocument({
    required String subcollection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    if (!_isAuthenticated) return;
    
    try {
      await _getSubcollection(subcollection).doc(documentId).update(data);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }
  
  /// Delete document
  Future<void> deleteDocument({
    required String subcollection,
    required String documentId,
  }) async {
    if (!_isAuthenticated) return;
    
    try {
      await _getSubcollection(subcollection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }
  
  /// Read all documents from subcollection
  Future<List<Map<String, dynamic>>> readAllDocuments({
    required String subcollection,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    if (!_isAuthenticated) return [];
    
    try {
      Query query = _getSubcollection(subcollection);
      
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      throw Exception('Failed to read documents: $e');
    }
  }
  
  /// Batch write operations
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    if (!_isAuthenticated) return;
    
    try {
      final batch = _firestore.batch();
      
      for (final operation in operations) {
        final type = operation['type'] as String;
        final subcollection = operation['subcollection'] as String;
        final documentId = operation['documentId'] as String;
        final data = operation['data'] as Map<String, dynamic>?;
        
        final docRef = _getSubcollection(subcollection).doc(documentId);
        
        switch (type) {
          case 'set':
            batch.set(docRef, data ?? {});
            break;
          case 'update':
            batch.update(docRef, data ?? {});
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to execute batch write: $e');
    }
  }
  
  /// Listen to document changes
  Stream<Map<String, dynamic>?> listenToDocument({
    required String subcollection,
    required String documentId,
  }) {
    if (!_isAuthenticated) {
      return Stream.value(null);
    }
    
    return _getSubcollection(subcollection)
        .doc(documentId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return {
          'id': snapshot.id,
          ...snapshot.data() as Map<String, dynamic>,
        };
      }
      return null;
    });
  }
  
  /// Listen to collection changes
  Stream<List<Map<String, dynamic>>> listenToCollection({
    required String subcollection,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) {
    if (!_isAuthenticated) {
      return Stream.value([]);
    }
    
    Query query = _getSubcollection(subcollection);
    
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    });
  }
  
  /// Query documents with where clause
  Future<List<Map<String, dynamic>>> queryDocuments({
    required String subcollection,
    required String field,
    required dynamic value,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    if (!_isAuthenticated) return [];
    
    try {
      Query query = _getSubcollection(subcollection).where(field, isEqualTo: value);
      
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      throw Exception('Failed to query documents: $e');
    }
  }
  
  /// Get document count
  Future<int> getDocumentCount(String subcollection) async {
    if (!_isAuthenticated) return 0;
    
    try {
      final snapshot = await _getSubcollection(subcollection).get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get document count: $e');
    }
  }
  
  /// Check if document exists
  Future<bool> documentExists({
    required String subcollection,
    required String documentId,
  }) async {
    if (!_isAuthenticated) return false;
    
    try {
      final doc = await _getSubcollection(subcollection).doc(documentId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check document existence: $e');
    }
  }
}

/// Riverpod provider for FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
