import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/style.dart';
import '../models/product_model.dart';
import '../services/cloudinary_service.dart';

class AppModals {
  static void showStatus({required BuildContext context, required String message, bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.transparent, elevation: 0, behavior: SnackBarBehavior.floating,
      content: Container(
        padding: const EdgeInsets.all(15), decoration: neoBox(color: isError ? AppColors.errorRed : AppColors.mintGreen, shadow: 4),
        child: Row(children: [Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white), const SizedBox(width: 12), Expanded(child: Text(message.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)))]),
      ),
    ));
  }

  static void showSaleDetail({required BuildContext context, required Map<String, dynamic> saleData}) {
    List items = saleData['items'] ?? [];
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (context) => Container(
      padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("TRANSACTION DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))]),
        const Divider(thickness: 2),
        Expanded(child: ListView.builder(itemCount: items.length, itemBuilder: (context, i) => ListTile(title: Text(items[i]['name'], style: const TextStyle(fontWeight: FontWeight.bold)), trailing: Text("x${items[i]['qty']}  ₱${(items[i]['price'] * items[i]['qty']).toStringAsFixed(2)}")))),
        Container(padding: const EdgeInsets.all(15), decoration: neoBox(color: AppColors.softYellow), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("TOTAL PAID", style: TextStyle(fontWeight: FontWeight.bold)), Text("₱${saleData['total'].toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))])),
      ]),
    ));
  }

  static void showProductForm({required BuildContext context, Product? product, required Function(Product) onSave}) {
    final isEditing = product != null;
    final nameCont = TextEditingController(text: isEditing ? product.name : "");
    final priceCont = TextEditingController(text: isEditing ? product.priceNum.toString() : "");
    final stockCont = TextEditingController(text: isEditing ? product.stockCount.toString() : "");
    final catCont = TextEditingController(text: isEditing ? product.cat : "Food & Beverages");
    File? selectedLocalImage;
    bool isUploading = false;

    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => StatefulBuilder(builder: (context, setModalState) => Container(
      height: MediaQuery.of(context).size.height * 0.85, decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25)), border: Border(top: BorderSide(width: 2))), padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(isEditing ? "EDIT PRODUCT" : "ADD NEW ITEM", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, size: 30))]),
        const SizedBox(height: 20),
        Center(child: Column(children: [
          Container(
            height: 100, width: 100, decoration: neoBox(color: AppColors.softYellow), 
            child: selectedLocalImage != null 
                ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(selectedLocalImage!, fit: BoxFit.cover)) 
                : (isEditing && product.imagePath != null && product.imagePath!.startsWith('http'))
                  ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(product.imagePath!, fit: BoxFit.cover))
                  : Center(child: Text(isEditing ? product.emoji : "📦", style: const TextStyle(fontSize: 40)))
          ),
          const SizedBox(height: 10),
          SizedBox(width: 150, child: neoButton(isUploading ? "UPLOADING..." : "UPLOAD IMAGE", Colors.white, Colors.black, () async {
            final img = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (img != null) setModalState(() => selectedLocalImage = File(img.path));
          })),
        ])),
        _field("PRODUCT NAME", nameCont), _field("CATEGORY", catCont),
        Row(children: [Expanded(child: _field("PRICE (₱)", priceCont, isNum: true)), const SizedBox(width: 10), Expanded(child: _field("STOCK", stockCont, isNum: true))]),
        const SizedBox(height: 30),
        
        neoButton(isUploading ? "PROCESSING..." : (isEditing ? "SAVE CHANGES" : "ADD TO INVENTORY"), isUploading ? Colors.grey : AppColors.gradientStart, Colors.white, () async {
          if (nameCont.text.trim().isEmpty || priceCont.text.trim().isEmpty || stockCont.text.trim().isEmpty || catCont.text.trim().isEmpty) {
            showStatus(context: context, message: "PLEASE FILL UP ALL TEXTFIELDS");
            return;
          }

          showConfirmation(
            context: context, 
            title: isEditing ? "Save changes?" : "Add to inventory?", 
            icon: isEditing ? Icons.edit_note : Icons.add_to_photos, 
            actionColor: AppColors.gradientStart, 
            onConfirm: () async {
              setModalState(() => isUploading = true);
              String? finalImageUrl = product?.imagePath;
              if (selectedLocalImage != null) {
                finalImageUrl = await CloudinaryService().uploadImage(selectedLocalImage!);
              }
              onSave(Product(
                id: product?.id, name: nameCont.text, 
                price: '₱${double.tryParse(priceCont.text)?.toStringAsFixed(2) ?? "0.00"}', 
                priceNum: double.tryParse(priceCont.text) ?? 0.0, 
                stockCount: int.tryParse(stockCont.text) ?? 0, cat: catCont.text, 
                emoji: isEditing ? product.emoji : "📦", 
                barcode: isEditing ? product.barcode : generateBarcode(), 
                imagePath: finalImageUrl
              ));
              setModalState(() => isUploading = false);
              if(context.mounted) Navigator.pop(context);
            }
          );
        }),
      ])),
    )));
  }

  static void showProductDetail({required BuildContext context, required Product product, required VoidCallback onDelete, required Function(Product) onEdit}) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.9, decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))), padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(children: [
          Container(
            height: 60, width: 60, decoration: neoBox(color: AppColors.softYellow, radius: 15), 
            child: (product.imagePath != null && product.imagePath!.startsWith('http'))
              ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(product.imagePath!, fit: BoxFit.cover, errorBuilder: (c, e, s) => Center(child: Text(product.emoji, style: const TextStyle(fontSize: 30))))) 
              : Center(child: Text(product.emoji, style: const TextStyle(fontSize: 30)))
          ),
          const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(product.cat, style: const TextStyle(color: Colors.grey))])),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ]),
        const SizedBox(height: 25), Row(children: [_grid(product.price, "PRICE", AppColors.boxPurple), const SizedBox(width: 10), _grid(product.stockEntry, "STOCK", AppColors.softYellow)]),
        const SizedBox(height: 20), 
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20), decoration: neoBox(shadow: 0), 
          child: Column(children: [
            const Text("BARCODE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            BarcodeWidget(
              barcode: Barcode.code128(), data: product.barcode,
              height: 100, width: double.infinity, drawText: true,
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
          ])
        ),
        const SizedBox(height: 15),
        Row(children: [
          Expanded(child: neoButton("SHARE", Colors.white, Colors.black, () {
            Share.share('Product: ${product.name}\nBarcode: ${product.barcode}');
          })),
          const SizedBox(width: 10),
          Expanded(child: neoButton("PRINT", Colors.white, Colors.black, () async {
            final doc = pw.Document();
            doc.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Column(children: [
              pw.Text(product.name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.BarcodeWidget(barcode: pw.Barcode.code128(), data: product.barcode, width: 300, height: 100),
            ]))));
            await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
          }))
        ]),
        const Spacer(),
        Row(children: [
          Expanded(child: neoButton("Edit", Colors.white, Colors.black, () { Navigator.pop(context); showProductForm(context: context, product: product, onSave: onEdit); })),
          const SizedBox(width: 10), 
          Expanded(child: neoButton("Delete", AppColors.errorRed.withValues(alpha: 0.1), Colors.red, () { 
            showConfirmation(
              context: context, title: "PERMANENTLY DELETE PRODUCT?", 
              icon: Icons.delete_forever, actionColor: AppColors.errorRed, 
              onConfirm: () { Navigator.pop(context); onDelete(); }
            );
          })),
        ])
      ]),
    ));
  }

  // UPDATED: neoButton now has press animation built-in
  static Widget neoButton(String label, Color bg, Color text, VoidCallback tap) {
    return _NeoAnimatedButton(label: label, bg: bg, text: text, tap: tap);
  }

  static String generateBarcode() => List.generate(12, (_) => Random().nextInt(10)).join();

  static Widget _grid(String v, String l, Color c) => Expanded(child: Container(height: 90, padding: const EdgeInsets.all(12), decoration: neoBox(color: c, shadow: 2), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)), const Spacer(), Text(v, style: const TextStyle(fontWeight: FontWeight.bold))])));
  
  static Widget _field(String l, TextEditingController c, {bool isNum = false}) => Padding(padding: const EdgeInsets.only(top: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), Container(decoration: neoBox(shadow: 2), child: TextField(controller: c, keyboardType: isNum ? TextInputType.number : TextInputType.text, decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 15))))]));

  static void showReceipt(BuildContext context, double total, VoidCallback onDone) {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: AppColors.bgWhite, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(width: 2)), content: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.check_circle_outline, color: AppColors.mintGreen, size: 70), const Text("SUCCESSFUL"), const Divider(), Text("₱${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 30), neoButton("NEW TRANSACTION", AppColors.gradientStart, Colors.white, () { Navigator.pop(context); onDone(); })])));
  }

  static void showConfirmation({required BuildContext context, required String title, required IconData icon, required Color actionColor, required VoidCallback onConfirm}) {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: AppColors.bgWhite, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(width: 2)), content: Column(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(12), decoration: neoBox(color: actionColor.withValues(alpha: 0.1), shadow: 0), child: Icon(icon, color: actionColor, size: 35)), const SizedBox(height: 20), Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center), const SizedBox(height: 25), Row(children: [Expanded(child: neoButton("Cancel", Colors.white, Colors.black, () => Navigator.pop(context))), const SizedBox(width: 10), Expanded(child: neoButton("Confirm", actionColor, Colors.white, () { Navigator.pop(context); onConfirm(); }))])])));
  }
}

// INTERNAL ANIMATED BUTTON COMPONENT
class _NeoAnimatedButton extends StatefulWidget {
  final String label;
  final Color bg;
  final Color text;
  final VoidCallback tap;
  const _NeoAnimatedButton({required this.label, required this.bg, required this.text, required this.tap});

  @override
  State<_NeoAnimatedButton> createState() => _NeoAnimatedButtonState();
}

class _NeoAnimatedButtonState extends State<_NeoAnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color displayColor = _isPressed 
      ? widget.bg.withValues(alpha: 0.7) // Darkens slightly when pressed
      : widget.bg;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.tap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: neoBox(color: displayColor, shadow: _isPressed ? 1 : 4),
        child: Center(child: Text(widget.label, style: TextStyle(color: widget.text, fontWeight: FontWeight.bold))),
      ),
    );
  }
}