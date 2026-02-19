import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyCartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ตะกร้าของฉัน")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('cart')
          .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final cartItems = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text("฿${item['price']}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => cartItems[index].reference.delete(),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => _checkout(context, cartItems),
                  child: const Text("สั่งซื้อสินค้า"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _checkout(BuildContext context, List<QueryDocumentSnapshot> items) async {
    final user = FirebaseAuth.instance.currentUser;
    for (var item in items) {
      final data = item.data() as Map<String, dynamic>;
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();

      // 1. ส่งไปยังประวัติการสั่งซื้อของลูกค้า
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('orders').doc(orderId).set({
        ...data,
        'orderId': orderId,
        'status': 'Waiting...',
        'orderDate': FieldValue.serverTimestamp(),
      });

      // 2. ส่งไปยังรายการออเดอร์เข้าของเจ้าของร้าน (shopId เก็บไว้ตอนเพิ่มลงตะกร้า)
      await FirebaseFirestore.instance.collection('users').doc(data['shopId']).collection('incoming_orders').doc(orderId).set({
        ...data,
        'orderId': orderId,
        'customerId': user.uid,
        'status': 'Waiting...',
        'orderDate': FieldValue.serverTimestamp(),
      });

      await item.reference.delete(); // ลบจากตะกร้า
    }
  }
}