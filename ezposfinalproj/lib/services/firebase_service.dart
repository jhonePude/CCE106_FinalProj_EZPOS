import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirebaseService {
  final CollectionReference _products = FirebaseFirestore.instance.collection('products');
  final CollectionReference _sales = FirebaseFirestore.instance.collection('sales');

  // Stream for Real-time Inventory
  Stream<List<Product>> getProducts() {
    return _products.snapshots().map((snap) {
      return snap.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // CRUD Operations
  Future<void> addProduct(Product p) => _products.add(p.toMap());
  
  Future<void> updateProduct(Product p) {
    if (p.id == null) return Future.value();
    return _products.doc(p.id).update(p.toMap());
  }

  Future<void> deleteProduct(String id) => _products.doc(id).delete();

  // Transaction Logic: Save Sale and Update Stock
  Future<void> processCheckout(List<Map<String, dynamic>> items, double total) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // 1. Record the sale
    DocumentReference saleRef = _sales.doc();
    batch.set(saleRef, {
      'total': total,
      'timestamp': FieldValue.serverTimestamp(),
      'items': items.map((e) => {
        'name': e['product'].name,
        'qty': e['qty'],
        'price': e['product'].priceNum
      }).toList()
    });

    // 2. Subtract stock for each product
    for (var item in items) {
      Product p = item['product'];
      if (p.id != null) {
        DocumentReference pRef = _products.doc(p.id);
        batch.update(pRef, {'stockCount': p.stockCount - (item['qty'] as int)});
      }
    }

    return batch.commit();
  }

  // Stream for Sales History
  Stream<QuerySnapshot> getSalesHistory() {
    return _sales.orderBy('timestamp', descending: true).snapshots();
  }
}