import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; 
import '../data/style.dart';
import '../widgets/app_modals.dart';
import '../services/firebase_service.dart';

class CheckoutPage extends StatefulWidget {
  final double total;
  final List<Map<String, dynamic>> items;
  final VoidCallback onDone;
  const CheckoutPage({super.key, required this.total, required this.items, required this.onDone});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  double cash = 0;
  bool get isInsufficient => cash < widget.total;
  final FirebaseService _db = FirebaseService();
  final AudioPlayer _audioPlayer = AudioPlayer(); 

  void _playPaySound() async {
    await _audioPlayer.play(AssetSource('sounds/apple_pay.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(elevation: 0, backgroundColor: AppColors.gradientStart, title: const Text("CHECKOUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        Container(padding: const EdgeInsets.all(15), decoration: neoBox(color: AppColors.softYellow), child: Column(children: [
          const Text("ORDER SUMMARY", style: TextStyle(fontWeight: FontWeight.bold)),
          ...widget.items.map((e) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${e['product'].name} x${e['qty']}"), Text("₱${(e['product'].priceNum * e['qty']).toStringAsFixed(2)}")]),),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total"), Text("₱${widget.total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]),
        ])),
        const SizedBox(height: 20),
        TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "CASH AMOUNT", prefixText: "₱ "), onChanged: (v) => setState(() => cash = double.tryParse(v) ?? 0)),
        const SizedBox(height: 15),
        Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: neoBox(color: isInsufficient ? AppColors.errorRed : AppColors.mintGreen), child: Text(isInsufficient ? "Insufficient Balance" : "Change: ₱${(cash - widget.total).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 30),
        AppModals.neoButton("PAY ₱${widget.total}", isInsufficient ? Colors.grey : Color.fromARGB(255, 76, 175, 80), Colors.white, () async {
          if (!isInsufficient) {
            AppModals.showConfirmation(
              context: context, 
              title: "Confirm Payment?", 
              icon: Icons.payment, 
              actionColor: Color.fromARGB(148, 76, 175, 79),
              onConfirm: () async {
                _playPaySound(); // SOUND TRIGGERED ONLY AFTER CONFIRMATION CLICK
                await _db.processCheckout(widget.items, widget.total); 
                if (mounted) AppModals.showReceipt(context, widget.total, () { Navigator.pop(context); widget.onDone(); });
              }
            );
          }
        }),
      ])),
    );
  }
}