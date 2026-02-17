import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jipatu_app/login_page.dart';

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
          decoration: BoxDecoration(
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
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
                      color: Color(0xFFEFEBE9),
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

                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .get(),
                    builder: (context, snapshot) {
                      String username = "Loading...";
                      if (snapshot.hasData && snapshot.data!.exists) {
                        username = snapshot.data!.get('username') ?? 'No Name';
                      }
                      return Column(
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            user?.email ?? 'No Email',
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

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
                        print("Go to Edit Profile");
                      },
                      bgColor: Color(0xFFFF5757),
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
                        print("Switch Mode");
                      },
                      bgColor: Color(0xFFFF5757),
                      iconColor: Colors.white,
                    ),
                    _buildMenuItem(
                      Icons.language_outlined, 
                      'Language', 
                      () {
                        print("Change Language");
                      },
                      bgColor:  Color(0xFFFF5757),
                      iconColor: Colors.white,         
                    ),
                    _buildMenuItem(
                      Icons.storefront, 
                      'Switch to My Shop', 
                      () {
                        print("Switching to Seller Mode...");
                      },
                      bgColor:  Color(0xFF34C759),
                      iconColor: Colors.white,
                    ),
                  ]),

/*                   const SizedBox(height: 20),

                  _buildSingleMenuCard(
                    Icons.storefront, 
                    'Switch to My Shop', 
                    () {
                      print("Switching to Seller Mode...");
                    },
                    isHighlight: true,
                    color: const Color(0xFF34C759),
                  ),
 */
                  const SizedBox(height: 30),

                  Center(
                    child: TextButton(
                      onPressed: () async {
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
                      },
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
      ),
    );
  }

/*   Widget _buildSingleMenuCard(IconData icon, String title, VoidCallback onTap, {bool isHighlight = false, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlight ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isHighlight ? Colors.white : Colors.brown[300], size: 26),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isHighlight ? Colors.white : const Color(0xFF424242),
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: isHighlight ? Colors.white : Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
 */
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
          color: iconColor ?? Color(0xFFFF5757), 
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
}