import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jipatu_app/customer/dashboard_page.dart';
import 'edit_shop_profile.dart';
import 'payment_info.dart';
import 'stock_main.dart';
import 'order_status.dart'; 

class MyShopPage extends StatefulWidget {
  final String? storeName;
  final String? description;
  final String? phone;
  final dynamic profileImage;

  const MyShopPage({
    super.key,
    this.storeName,
    this.description,
    this.phone,
    this.profileImage,
  });
  
  @override
  State<MyShopPage> createState() => _MyShopPageState();
}

class _MyShopPageState extends State<MyShopPage> {
  bool isOpen = false;
  bool _isLoading = true;
  
  String displayName = "";
  String displayDesc = "";
  String displayPhone = "";
  dynamic displayImage;

  @override
  void initState() {
    super.initState();
    if (widget.storeName != null) {
      displayName = widget.storeName!;
      displayDesc = widget.description ?? "";
      displayPhone = widget.phone ?? "";
      displayImage = widget.profileImage;
      _isLoading = false;
      _fetchShopData();
    } else {
      _fetchShopData();
    }
  }

  Future<void> _updateShopStatus(bool status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final batch = FirebaseFirestore.instance.batch();

        // 1. หาเอกสารใน users > uid > shop เพื่ออัปเดต
        final userShopSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('shop')
            .limit(1)
            .get();

        if (userShopSnapshot.docs.isNotEmpty) {
          batch.update(userShopSnapshot.docs.first.reference, {
            'isOpen': status,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }

        // 2. หาเอกสารใน shops (คอลเลกชันหลัก) ที่มี ownerUid ตรงกับ user.uid
        final globalShopSnapshot = await FirebaseFirestore.instance
            .collection('shops')
            .where('ownerUid', isEqualTo: user.uid)
            .limit(1)
            .get();

        if (globalShopSnapshot.docs.isNotEmpty) {
          batch.update(globalShopSnapshot.docs.first.reference, {
            'isOpen': status,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }

        // ทำการ commit batch เพื่ออัปเดตทั้งสองที่พร้อมกัน
        await batch.commit();

      } catch (e) {
        debugPrint("Error updating shop status: $e");
      }
    }
  }

  Future<void> _fetchShopData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('shop')
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final data = snapshot.docs.first.data();
          setState(() {
            displayName = data['storeName'] ?? "";
            displayDesc = data['description'] ?? "";
            displayPhone = data['phone'] ?? "";
            displayImage = data['profileImage'];
            isOpen = data['isOpen'] ?? false; 
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Error fetching shop: $e");
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    ImageProvider? imageProvider;
    if (displayImage is XFile) {
      imageProvider = kIsWeb
          ? NetworkImage((displayImage as XFile).path)
          : FileImage(File((displayImage as XFile).path)) as ImageProvider;
    } else if (displayImage is String && displayImage.toString().isNotEmpty) {
      imageProvider = NetworkImage(displayImage);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 250,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD32F2F), Color(0xFFFFB300)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      "My Shop",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 70),

              Text(
                displayName.isEmpty ? "No Name" : displayName,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Text(
                displayPhone.isEmpty ? "No Phone" : displayPhone,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.receipt_long, 
                        color: Colors.orange, 
                        text: 'Incoming Orders',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderStatusPage()));
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.edit,
                        color: const Color(0xFFEF5350),
                        text: 'Edit Shop Profile',
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditShopProfile(
                                currentStoreName: displayName,
                                currentDesc: displayDesc,
                                currentPhone: displayPhone,
                                currentImage: displayImage,
                              ),
                            ),
                          );

                          if (result != null && result is Map<String, dynamic>) {
                            setState(() {
                              displayName = result['name'];
                              displayDesc = result['desc'];
                              displayPhone = result['phone'];
                              displayImage = result['image'];
                            });
                          }
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.payment,
                        color: const Color(0xFFEF5350),
                        text: 'Payment Info',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentInfoPage()));
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        color: const Color(0xFF4CAF50),
                        text: 'Switch to My Profile',
                        onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const DashboardPage()),
                            );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildOpenCloseToggle(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            top: 185,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: imageProvider,
                  child: displayImage == null ? const Icon(Icons.person, size: 70, color: Colors.grey) : null,
                ),
              ),
            ),
          ),
          _buildFloatingNavBar(),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required Color color, required String text, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15)),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color, radius: 22, child: Icon(icon, color: Colors.white, size: 24)),
              const SizedBox(width: 20),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpenCloseToggle() {
    return Container(
      width: 200,
      height: 50,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => isOpen = true);
                _updateShopStatus(true);
              },
              child: Container(
                decoration: BoxDecoration(color: isOpen ? const Color(0xFF66BB6A) : Colors.transparent, borderRadius: BorderRadius.circular(30)),
                alignment: Alignment.center,
                child: Text("Open", style: TextStyle(color: isOpen ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => isOpen = false);
                _updateShopStatus(false);
              },
              child: Container(
                decoration: BoxDecoration(color: !isOpen ? const Color(0xFF750020) : Colors.transparent, borderRadius: BorderRadius.circular(30)),
                alignment: Alignment.center,
                child: Text("Close", style: TextStyle(color: !isOpen ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFD84315), Color(0xFFFFB300)]),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderStatusPage()),
                );
              }, 
              icon: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 30),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.home_outlined, color: Colors.white, size: 30)),
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StockMainPage())),
              icon: const Icon(Icons.inbox, color: Colors.white, size: 30),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.storefront, color: Colors.black, size: 30)),
          ],
        ),
      ),
    );
  }
}