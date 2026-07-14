import 'package:flutter/material.dart';
import '../data/style.dart';
import '../models/product_model.dart';
import '../widgets/app_modals.dart';
import '../services/firebase_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String searchQuery = "";
  final FirebaseService _db = FirebaseService();
  bool _isAddPressed = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: _db.getProducts(),
      builder: (context, snapshot) {
        List<Product> products = snapshot.data ?? [];

        List<Product> filtered = products
            .where((p) =>
                p.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

        int lowStock =
            products.where((p) => p.stockCount <= 10).length;

        return Scaffold(
          backgroundColor: AppColors.bgWhite,
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 60, bottom: 20, left: 20, right: 20),
                decoration: neoGradientBox(),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          decoration: neoBox(
                            color: AppColors.softYellow,
                            shadow: 1,
                            radius: 8,
                          ),
                          child: const Text(
                            "📦 INVENTORY",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTapDown: (_) =>
                              setState(() => _isAddPressed = true),
                          onTapUp: (_) =>
                              setState(() => _isAddPressed = false),
                          onTapCancel: () =>
                              setState(() => _isAddPressed = false),
                          onTap: () => AppModals.showProductForm(
                            context: context,
                            onSave: (p) => _db.addProduct(p),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: neoBox(
                              color: _isAddPressed
                                  ? const Color(0xFF00A37D)
                                  : AppColors.mintGreen,
                              shadow: _isAddPressed ? 1 : 3,
                            ),
                            child: const Text(
                              "✚ ADD ITEM",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        _stat("${products.length}", "🛍️ ITEMS"),
                        const SizedBox(width: 10),
                        _stat(
                          "$lowStock",
                          "⚠️ LOW STOCK",
                          color: AppColors.errorRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: neoBox(shadow: 2),
                  child: TextField(
                    onChanged: (v) =>
                        setState(() => searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: "Search Item...",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    bool isLow = item.stockCount <= 10;

                    return GestureDetector(
                      onTap: () => AppModals.showProductDetail(
                        context: context,
                        product: item,
                        onDelete: () =>
                            _db.deleteProduct(item.id!),
                        onEdit: (u) => _db.updateProduct(u),
                      ),
                      child: Container(
                        margin:
                            const EdgeInsets.only(bottom: 13),
                        padding: const EdgeInsets.all(15),
                        decoration: neoBox(),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(10),
                              child: item.imagePath != null &&
                                      item.imagePath!
                                          .isNotEmpty
                                  ? Image.network(
                                      item.imagePath!,
                                      width: 55,
                                      height: 55,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context,
                                          child,
                                          loadingProgress) {
                                        if (loadingProgress ==
                                            null) {
                                          return child;
                                        }

                                        return Container(
                                          width: 55,
                                          height: 55,
                                          alignment:
                                              Alignment.center,
                                          child:
                                              const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context,
                                          error,
                                          stackTrace) {
                                        return Container(
                                          width: 55,
                                          height: 55,
                                          decoration:
                                              BoxDecoration(
                                            color: Colors
                                                .grey.shade200,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        10),
                                          ),
                                          child: const Icon(
                                            Icons
                                                .image_not_supported,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 55,
                                      height: 55,
                                      decoration:
                                          BoxDecoration(
                                        color: Colors
                                            .grey.shade200,
                                        borderRadius:
                                            BorderRadius
                                                .circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          item.emoji,
                                          style:
                                              const TextStyle(
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Stock: ${item.stockCount} pcs",
                                    style: TextStyle(
                                      color: isLow
                                          ? Colors.red
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (isLow)
                              const Icon(
                                Icons.warning,
                                color: Colors.red,
                              ),

                            const Icon(
                                Icons.chevron_right),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(
    String v,
    String l, {
    Color color = Colors.white12,
  }) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration:
              neoBox(color: color, shadow: 0),
          child: Column(
            children: [
              Text(
                v,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
}