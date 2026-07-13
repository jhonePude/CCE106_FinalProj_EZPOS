class Product {
  String? id; // This is the unique ID from Firebase
  String name;
  String price; // Formatted price (₱0.00)
  double priceNum; // Raw number for math
  int stockCount; // Integer for stock management
  String cat;
  String emoji;
  String barcode;
  String? imagePath;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.priceNum,
    required this.stockCount,
    required this.cat,
    required this.emoji,
    required this.barcode,
    this.imagePath,
  });

  String get stockEntry => "$stockCount pcs";

  // ADD THIS: Convert Product to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'priceNum': priceNum,
      'stockCount': stockCount,
      'cat': cat,
      'emoji': emoji,
      'barcode': barcode,
      'imagePath': imagePath,
    };
  }

  // ADD THIS: Create Product from Firebase Map
  static Product fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      priceNum: (map['priceNum'] ?? 0).toDouble(),
      stockCount: map['stockCount'] ?? 0,
      cat: map['cat'] ?? '',
      emoji: map['emoji'] ?? '📦',
      barcode: map['barcode'] ?? '',
      imagePath: map['imagePath'],
    );
  }
}