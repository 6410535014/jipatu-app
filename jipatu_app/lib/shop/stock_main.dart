import 'package:flutter/material.dart';
// 1. นำเข้า Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_stock.dart';

class StockMainPage extends StatefulWidget {
  const StockMainPage({super.key});

  @override
  State<StockMainPage> createState() => _StockMainPageState();
}

class _StockMainPageState extends State<StockMainPage> {
  // ลบสินค้า
  Future<void> _deleteProduct(DocumentReference productRef) async {
    try {
      await productRef.delete();
    } catch (e) {
      debugPrint("Error deleting product: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Management"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD32F2F), Color(0xFFFFB300)],
            ),
          ),
        ),
      ),
      body: user == null
          ? const Center(child: Text("Please login first"))
          : StreamBuilder<QuerySnapshot>(
              // Query ไปยัง products ของร้านค้า
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('shop')
                  .limit(1)
                  .snapshots()
                  .asyncMap((shopSnapshot) async {
                if (shopSnapshot.docs.isEmpty) return null;
                return shopSnapshot.docs.first.reference
                    .collection('products')
                    .orderBy('createdAt', descending: true)
                    .snapshots();
              }).switchMap((stream) => stream ?? Stream.empty()),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(child: Text("No products in stock"));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        // Icon cart
                        leading: const CircleAvatar(
                          backgroundColor: Colors.amberAccent,
                          child: Icon(Icons.shopping_cart, color: Colors.black),
                        ),
                        // ชื่อสินค้า
                        title: Text(
                          data['name'] ?? "No Name",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        // รายละเอียด, ราคา
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
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(doc.reference),
                        ),
                        onTap: () {
                          // ส่งข้อมูลไปแก้ไขที่หน้า AddStockPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddStockPage(
                                existingItem: {
                                  'id': doc.id,
                                  'name': data['name'],
                                  'desc': data['desc'],
                                  'price': data['price'],
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStockPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

// Extension ช่วยจัดการ Stream ที่ซ้อนกัน
extension StreamMap<T> on Stream<T> {
  Stream<R> switchMap<R>(Stream<R>? Function(T) transform) {
    return asyncExpand((event) => transform(event) ?? const Stream.empty());
  }
}