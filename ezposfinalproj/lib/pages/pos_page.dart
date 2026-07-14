import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart'; // ADDED
import '../data/style.dart';
import '../models/product_model.dart';
import '../widgets/app_modals.dart';
import '../services/firebase_service.dart';
import 'checkout_page.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});
  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  List<Map<String, dynamic>> cart = [];
  final FirebaseService _db = FirebaseService();
  final AudioPlayer _audioPlayer = AudioPlayer(); // ADDED

  void _playPop() async {
    await _audioPlayer.stop(); // Stop current sound to allow rapid clicking
    await _audioPlayer.play(AssetSource('sounds/pop.mp3'));
  }

  void adjustQuantity(Product p, int delta) {
    setState(() {
      int index = cart.indexWhere((element) => element['product'].id == p.id);
      if (index != -1) {
        cart[index]['qty'] += delta;
        if (cart[index]['qty'] <= 0) {
          cart.removeAt(index);
        }
      }
    });
  }

  void addToCart(BuildContext context, Product p) {
    if (p.stockCount <= 0) {
      AppModals.showStatus(context: context, message: "OUT OF STOCK");
      return;
    }
    _playPop(); // SOUND TRIGGERED HERE
    setState(() {
      var index = cart.indexWhere((element) => element['product'].id == p.id);
      if (index == -1) {
        cart.add({'product': p, 'qty': 1});
      } else if (cart[index]['qty'] < p.stockCount) {
        cart[index]['qty']++;
      }
      AppModals.showStatus(
        context: context, 
        message: "ADDED ${p.name.toUpperCase()} TO CART", 
        isError: false
      );
    });
  }

  void openSearchPopup(List<Product> allProducts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (context, setModalState) {
          String localQuery = "";
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
              decoration: const BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(top: BorderSide(width: 2)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text("SEARCH PRODUCTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 30)),
                ]),
                const SizedBox(height: 15),
                Container(
                  decoration: neoBox(shadow: 2),
                  child: TextField(
                    autofocus: true,
                    onChanged: (v) => setModalState(() => localQuery = v),
                    decoration: const InputDecoration(hintText: "Type product name...", prefixIcon: Icon(Icons.search), border: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: allProducts
                        .where((p) => p.name.toLowerCase().contains(localQuery.toLowerCase()))
                        .map((p) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: neoBox(shadow: 2),
                          child: ListTile(
                            // UPDATED: Now uses identical fallback image structure as your Inventory screen
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: p.imagePath != null && p.imagePath!.isNotEmpty
                                  ? Image.network(
                                      p.imagePath!,
                                      width: 45,
                                      height: 45,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          width: 45,
                                          height: 45,
                                          alignment: Alignment.center,
                                          child: const SizedBox(
                                            width: 15,
                                            height: 15,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          p.emoji,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                            ),
                            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(p.price),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle, color: AppColors.gradientStart, size: 30),
                              onPressed: () {
                                addToCart(context, p);
                              },
                            ),
                          ),
                        )).toList(),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  void openScanner(List<Product> allProducts) {
    final MobileScannerController scannerController = MobileScannerController(autoStart: true, facing: CameraFacing.back, detectionSpeed: DetectionSpeed.normal, returnImage: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (modalContext) => Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(children: [
            const Padding(padding: EdgeInsets.only(top: 40, bottom: 20), child: Text("SCAN BARCODE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            Expanded(
              child: MobileScanner(
                controller: scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final String? code = barcodes.first.rawValue;
                    if (code != null) {
                      try {
                        final p = allProducts.firstWhere((e) => e.barcode == code);
                        addToCart(modalContext, p);
                        Future.delayed(const Duration(milliseconds: 800), () {
                          if (mounted) {
                            scannerController.stop();
                            scannerController.dispose();
                            Navigator.pop(modalContext);
                          }
                        });
                      } catch (e) {
                        debugPrint("Not found");
                      }
                    }
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: AppModals.neoButton("CLOSE", Colors.white, Colors.black, () {
                scannerController.stop();
                scannerController.dispose();
                Navigator.pop(modalContext);
              }),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: _db.getProducts(),
      builder: (context, snapshot) {
        List<Product> products = snapshot.data ?? [];
        double total = cart.fold(0, (sum, item) => sum + (item['product'].priceNum * item['qty']));

        return Scaffold(
          backgroundColor: AppColors.bgWhite,
          body: Column(children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
              decoration: neoGradientBox(),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: neoBox(color: AppColors.softYellow, shadow: 1, radius: 8),
                    child: const Text("🖥️ POINT OF SALE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  Container(padding: const EdgeInsets.all(8), decoration: neoBox(color: Colors.white, shadow: 1), child: Text("${cart.length} ITEMS", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)))
                ]),
                const SizedBox(height: 25),
                Row(children: [
                  _headerBtn(Icons.qr_code_scanner, "SCAN", () => openScanner(products)),
                  const SizedBox(width: 15),
                  _headerBtn(Icons.search, "SEARCH", () => openSearchPopup(products)),
                ]),
              ]),
            ),

            Expanded(
              child: cart.isEmpty
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.all(30),
                        padding: const EdgeInsets.all(40),
                        decoration: neoBox(color: const Color.fromARGB(55, 134, 130, 130), shadow: 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shopping_cart, size: 80, color: Color.fromARGB(255, 0, 0, 0)),
                            const SizedBox(height: 20),
                            const Text("EMPTY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -1)),
                            const SizedBox(height: 5),
                           
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        final item = cart[index];
                        final Product p = item['product'];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: neoBox(shadow: 2),
                          child: ListTile(
                            leading: Text(p.emoji, style: const TextStyle(fontSize: 24)),
                            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("₱${(p.priceNum * item['qty']).toStringAsFixed(2)}"),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              _qtyBtn(Icons.remove, () => adjustQuantity(p, -1), color: AppColors.errorRed),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text("${item['qty']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              _qtyBtn(Icons.add, () => adjustQuantity(p, 1), color: AppColors.mintGreen),
                            ]),
                          ),
                        );
                      },
                    ),
            ),

            if (cart.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(width: 2))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("TOTAL AMOUNT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    Text("₱${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ]),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 76, 175, 80), foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(width: 2)),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage(total: total, items: cart, onDone: () => setState(() => cart.clear())))),
                    child: const Text("CHECKOUT", style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ]),
              )
          ]),
        );
      },
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback tap, {required Color color}) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6), border: Border.all(width: 1.5)),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _headerBtn(IconData i, String l, VoidCallback t) {
    return _POSHeaderButton(icon: i, label: l, onTap: t);
  }
}

class _POSHeaderButton extends StatefulWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _POSHeaderButton({required this.icon, required this.label, required this.onTap});
  @override
  State<_POSHeaderButton> createState() => _POSHeaderButtonState();
}

class _POSHeaderButtonState extends State<_POSHeaderButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: neoBox(color: _isPressed ? Colors.grey[200]! : Colors.white, shadow: _isPressed ? 1 : 4, radius: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(widget.icon, color: Colors.black, size: 18),
            const SizedBox(width: 8),
            Text(widget.label, style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold))
          ]),
        ),
      ),
    );
  }
}