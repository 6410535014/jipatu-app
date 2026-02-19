import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("สรุปยอดขาย", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFFFB300)]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryChart(title: "ยอดขาย 1 วัน", days: 1),
            const SizedBox(height: 20),
            _buildSummaryChart(title: "ยอดขาย 1 สัปดาห์", days: 7),
            const SizedBox(height: 20),
            _buildSummaryChart(title: "ยอดขาย 1 เดือน", days: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryChart({required String title, required int days}) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('incoming_orders')
          .where('status', isEqualTo: 'Accepted')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("Error: ${snapshot.error}");
        
        double totalSales = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            print("Found Order: ${data['name']} Price: ${data['price']}");
            
            String priceStr = data['price'].toString().replaceAll('฿', '').trim();
            totalSales += (double.tryParse(priceStr) ?? 0);
          }
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                  ),
                  Container(
                    height: 20,
                    width: (totalSales / 10000).clamp(0, 1) * 300,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.green, Colors.lightGreenAccent]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text("ยอดขายรวม: ฿${totalSales.toStringAsFixed(2)}", 
                style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}