import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_shop_page.dart';
import 'user_register_shop.dart';

class SelectShopPage extends StatelessWidget {
  const SelectShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("ร้านค้าของคุณ")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('shop')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final shops = snapshot.data?.docs ?? [];

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: shops.length,
                  itemBuilder: (context, index) {
                    final data = shops[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.store),
                      title: Text(data['storeName'] ?? 'No Name'),
                      subtitle: Text(data['phone'] ?? ''),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => MyShopPage(
                            storeName: data['storeName'],
                            description: data['description'],
                            phone: data['phone'],
                            profileImage: data['profileImage'],
                          ),
                        ));
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("สร้างร้านค้าใหม่"),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => const UserRegisterShopPage(),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}