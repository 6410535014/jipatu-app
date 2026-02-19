import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderStatusPage extends StatelessWidget {
  const OrderStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Status", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFFFB300)]),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('incoming_orders')
            .orderBy('orderDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("เกิดข้อผิดพลาด"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data?.docs ?? [];
          if (orders.isEmpty) return const Center(child: Text("ไม่มีออเดอร์ใหม่"));

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;
              final String currentStatus = data['status'] ?? 'Pending';
              
              // ตรวจสอบว่าสถานะถูกเปลี่ยนไปจาก Pending หรือยัง (เพื่อใช้ล็อกปุ่ม)
              final bool isLocked = currentStatus != 'Pending';

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? "Unknown Product", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 5),
                      // แสดงชื่อผู้ซื้อ (Username)
                      Text("Customer: ${data['customerName'] ?? 'Anonymous'}", style: const TextStyle(fontSize: 14)),
                      // แสดงราคา
                      Text("Price: ฿${data['price'] ?? '0'}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text("Status: $currentStatus", 
                        style: TextStyle(
                          color: _getStatusColor(currentStatus),
                          fontWeight: FontWeight.bold
                        )
                      ),
                      const Divider(),
                      
                      // ปุ่ม Accept และ Decline
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isLocked ? Colors.grey : Colors.green, // เปลี่ยนสีถ้าล็อกแล้ว
                              ),
                              // ถ้า isLocked เป็นจริง (ไม่ใช่ Pending) จะคืนค่า null เพื่อ Disable ปุ่ม
                              onPressed: isLocked ? null : () => _updateStatus(doc, 'Accepted'),
                              child: const Text("Accept", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isLocked ? Colors.grey : Colors.red, // เปลี่ยนสีถ้าล็อกแล้ว
                              ),
                              // ถ้า isLocked เป็นจริง จะคืนค่า null เพื่อ Disable ปุ่ม
                              onPressed: isLocked ? null : () => _updateStatus(doc, 'Declined'),
                              child: const Text("Decline", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      if (isLocked) 
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Center(child: Text("ดำเนินการแล้ว", style: TextStyle(color: Colors.grey, fontSize: 12))),
                        )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Accepted') return Colors.green;
    if (status == 'Declined') return Colors.red;
    return Colors.orange; // For Pending
  }

  void _updateStatus(DocumentSnapshot shopOrderDoc, String newStatus) async {
    final data = shopOrderDoc.data() as Map<String, dynamic>;
    final String orderId = data['orderId'];
    final String customerId = data['customerId'];

    // 1. อัปเดตฝั่งร้านค้า
    await shopOrderDoc.reference.update({'status': newStatus});

    // 2. อัปเดตฝั่งลูกค้า (ต้องระบุ path ให้ตรงกับที่ลูกค้าดึงข้อมูล)
    await FirebaseFirestore.instance
        .collection('users')
        .doc(customerId)
        .collection('orders')
        .doc(orderId)
        .update({'status': newStatus});
  }
}