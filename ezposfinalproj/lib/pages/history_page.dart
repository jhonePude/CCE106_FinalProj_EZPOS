import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/style.dart';
import '../services/firebase_service.dart';
import '../widgets/app_modals.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseService _db = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.getSalesHistory(),
        builder: (context, snapshot) {
          double totalRev = 0;
          int txn = snapshot.data?.docs.length ?? 0;
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) { totalRev += (doc['total'] ?? 0); }
          }
          return Column(children: [
            Container(padding: const EdgeInsets.only(top: 60, bottom: 25, left: 20, right: 20), decoration: neoGradientBox(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // UPDATED: NEO-BRUTALIST TITLE LABEL
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: neoBox(color: AppColors.softYellow, shadow: 1, radius: 8),
                child: const Text("SALES HISTORY", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              Row(children: [_statBox("TOTAL REVENUE", "₱${totalRev.toStringAsFixed(2)}", AppColors.softYellow), const SizedBox(width: 15), _statBox("TXN COUNT", "$txn", const Color(0xFFB191FF))]),
            ])),
            Expanded(
              child: snapshot.data == null || snapshot.data!.docs.isEmpty 
              ? const Center(child: Text("NO SALES FOUND", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black26)))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    return GestureDetector(
                      onTap: () => AppModals.showSaleDetail(context: context, saleData: data),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(15), decoration: neoBox(),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString().substring(0, 16) : "RECENT", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 5), Text("₱${data['total'].toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ]),
                          const Icon(Icons.receipt_long, color: Colors.black),
                        ]),
                      ),
                    );
                  }
                ),
            )
          ]);
        }
      ),
    );
  }
  Widget _statBox(String l, String v, Color c) => Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: neoBox(color: c, shadow: 2), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)), Text(v, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))])));
}