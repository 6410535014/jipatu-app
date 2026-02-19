import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyCartPage extends StatelessWidget {
  const MyCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ตะกร้าของฉัน", style: TextStyle(color: Colors.white)),
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
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("เกิดข้อผิดพลาด"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartItems = snapshot.data?.docs ?? [];
          if (cartItems.isEmpty) return const Center(child: Text("ไม่มีสินค้าในตะกร้า"));

          double totalPrice = cartItems.fold(0, (sum, item) {
            final data = item.data() as Map<String, dynamic>;
            return sum + (double.tryParse(data['price'].toString()) ?? 0);
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final data = cartItems[index].data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text(data['name'] ?? ""),
                        subtitle: Text("฿${data['price']}", style: const TextStyle(color: Colors.red)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () => cartItems[index].reference.delete(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("ราคารวมทั้งหมด:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("฿${totalPrice.toStringAsFixed(2)}", 
                          style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _showConfirmOrderDialog(context, cartItems, user!.uid),
                        child: const Text("สั่งซื้อสินค้า", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showConfirmOrderDialog(BuildContext context, List<QueryDocumentSnapshot> items, String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    
    String? username = userDoc.exists ? (userDoc.data() as Map<String, dynamic>)['username'] : null;
    
    String finalCustomerName = username ?? FirebaseAuth.instance.currentUser?.displayName ?? "ไม่ระบุชื่อ";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยันการสั่งซื้อ"),
        content: Text("คุณต้องการสั่งซื้อสินค้าจำนวน ${items.length} รายการใช่หรือไม่?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ยกเลิก")),
          ElevatedButton(
            onPressed: () {
              _checkout(context, items, uid, finalCustomerName);
              Navigator.pop(context);
            },
            child: const Text("ยืนยันการสั่งซื้อ"),
          ),
        ],
      ),
    );
  }

  void _checkout(BuildContext context, List<QueryDocumentSnapshot> items, String uid, String customerName) async {
    for (var item in items) {
      final data = item.data() as Map<String, dynamic>;
      final orderId = DateTime.now().millisecondsSinceEpoch.toString() + items.indexOf(item).toString();

      await FirebaseFirestore.instance.collection('users').doc(uid).collection('orders').doc(orderId).set({
        ...data,
        'orderId': orderId,
        'status': 'Pending',
        'orderDate': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('users').doc(data['shopId']).collection('incoming_orders').doc(orderId).set({
        ...data,
        'orderId': orderId,
        'customerId': uid,
        'customerName': customerName,
        'status': 'Pending',
        'orderDate': FieldValue.serverTimestamp(),
        'price': data['price'],
      });

      await item.reference.delete();
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("สั่งซื้อสินค้าสำเร็จ!")));
  }
}