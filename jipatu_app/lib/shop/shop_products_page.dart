import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopProductsPage extends StatelessWidget {
  final String shopId;
  final String shopName;

  const ShopProductsPage({super.key, required this.shopId, required this.shopName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shopName),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD32F2F), Color(0xFFFFB300)],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ดึงข้อมูลสินค้าจาก products ภายใต้ร้านค้านั้น ๆ
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(shopId)
            .collection('shop')
            .limit(1)
            .snapshots()
            .asyncMap((shopSnapshot) async {
          if (shopSnapshot.docs.isEmpty) return null;
          return shopSnapshot.docs.first.reference
              .collection('products')
              .orderBy('createdAt', descending: true)
              .snapshots();
        }).asyncExpand((stream) => stream ?? const Stream.empty()),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text("No products available"));

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.amberAccent,
                    child: Icon(Icons.shopping_cart, color: Colors.black),
                  ),
                  title: Text(
                    data['name'] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['desc'] ?? ""),
                      Text(
                        "฿${data['price'] ?? '0'}",
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  onTap: () {
                    _showAddToCartDialog(context, data);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  void _showAddToCartDialog(BuildContext context, Map<String, dynamic> productData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("เพิ่มลงในตะกร้า?"),
        content: Text("ต้องการเพิ่ม ${productData['name']} ลงในตะกร้าใช่หรือไม่?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ยกเลิก")),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('cart')
                    .add({
                  'productId': productData['id'],
                  'name': productData['name'],
                  'price': productData['price'],
                  'shopId': shopId, 
                  'customerName': user.displayName ?? "Customer",
                  'addedAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              }
            },
            child: const Text("เพิ่ม"),
          ),
        ],
      ),
    );
  }
}