import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jipatu_app/customer/login_page.dart';
import 'package:jipatu_app/shop/user_register_shop.dart';
import 'package:jipatu_app/shop/select_shop_page.dart'; 

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF650620),
                Color(0xFFFF5757),
                Color(0xFFFED158),
              ],
            ),
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get(),
        builder: (context, snapshot) {
          String username = "Loading...";
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            username = data['username'] ?? 'No Name';
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(username, user?.email),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMenuSection([
                        _buildMenuItem(
                          Icons.edit_outlined,
                          'Edit Profile',
                          () {
                            debugPrint("Go to Edit Profile");
                          },
                          bgColor: const Color(0xFFFF5757),
                          iconColor: Colors.white,
                        ),
                      ]),
                      const SizedBox(height: 25),
                      const Text(
                        "General Settings",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildMenuSection([
                        _buildMenuItem(
                          Icons.dark_mode_outlined,
                          'Mode (Dark & Light)',
                          () {
                            debugPrint("Switch Mode");
                          },
                          bgColor: const Color(0xFFFF5757),
                          iconColor: Colors.white,
                        ),
                        _buildMenuItem(
                          Icons.language_outlined,
                          'Language',
                          () {
                            debugPrint("Change Language");
                          },
                          bgColor: const Color(0xFFFF5757),
                          iconColor: Colors.white,
                        ),
                        _buildMenuItem(
                          Icons.storefront,
                          'Switch to My Shop',
                          () => _handleShopNavigation(context, user?.uid),
                          bgColor: const Color(0xFF34C759),
                          iconColor: Colors.white,
                        ),
                      ]),
                      const SizedBox(height: 30),
                      Center(
                        child: TextButton(
                          onPressed: () => _showSignOutDialog(context),
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleShopNavigation(BuildContext context, String? uid) async {
    if (uid == null) return;

    try {
      final shopSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('shop')
          .get();

      if (!context.mounted) return;

      if (shopSnapshot.docs.isEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserRegisterShopPage()),
        );
      } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SelectShopPage()),
          );
      }
    } catch (e) {
      debugPrint("Error checking shop data: $e");
    }
  }

  Widget _buildProfileHeader(String username, String? email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 70, bottom: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFEFEBE9),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFEFEBE9),
              child: Icon(Icons.person, size: 55, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            email ?? 'No Email',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {Color? bgColor, Color? iconColor}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? const Color(0xFFFF5757),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, color: Color(0xFF424242)),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              child: const Text('ตกลง', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}