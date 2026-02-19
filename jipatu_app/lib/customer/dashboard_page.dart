import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  String _searchQuery = ""; // สำหรับเก็บคำค้นหา
  String? _selectedCategory; // เพิ่มตัวแปรนี้ด้านบนคู่กับ _searchQuery

  // เปลี่ยน _pages ให้เป็นฟังก์ชันหรือเก็บค่าแบบ Dynamic เพื่อให้รับค่าการค้นหาได้
  List<Widget> _getPages() {
    return [
      _buildHomeContent(), // หน้าหลักที่มี Search และรายการร้านค้า
      const Center(child: Text('Your Cart')),
      const Center(child: Text('Your Orders')),
      const ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- ส่วนประกอบของหน้า Home ---

Widget _buildHomeContent() {
    return SafeArea(
      child: Column(
        children: [
          // 1. Search Box พร้อมการไล่สี
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                // กำหนดการไล่สีจาก FFD359 ไป FF5757
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD359), Color(0xFFFF5757)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value.trim()),
                style: const TextStyle(color: Colors.black), // ปรับสีตัวอักษรให้เข้ากับพื้นหลัง
                decoration: InputDecoration(
                  hintText: "Search store name...",
                  hintStyle: const TextStyle(color: Colors.black),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  border: InputBorder.none, // ลบเส้นขอบเดิมออก
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories และ Shop List (โค้ดเดิม)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("Categories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  _buildCategoryList(),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("Shops", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  _buildShopList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = [
      {'name': 'Food & Drink', 'icon': Icons.fastfood},
      {'name': 'Fashion', 'icon': Icons.checkroom},
      {'name': 'Electronics', 'icon': Icons.devices},
      {'name': 'Service', 'icon': Icons.build},
      {'name': 'Other', 'icon': Icons.more_horiz},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final catName = categories[index]['name'] as String;
          final isSelected = _selectedCategory == catName;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  // ถ้ากดซ้ำที่เดิมให้ยกเลิกการกรอง (แสดงทั้งหมด) ถ้ากดอันใหม่ให้กรองตามอันนั้น
                  _selectedCategory = isSelected ? null : catName;
                });
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    // เปลี่ยนสีพื้นหลังถ้าถูกเลือก
                    backgroundColor: isSelected ? Colors.orange[700] : const Color(0xFFFFD54F),
                    child: Icon(
                      categories[index]['icon'] as IconData, 
                      color: isSelected ? Colors.white : Colors.black
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    catName, 
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.orange[700] : Colors.black
                    )
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopList() {
    // ดึงข้อมูลจากคอลเลกชัน 'shops' หลัก
    Query query = FirebaseFirestore.instance.collection('shops');

    // ถ้ามีการพิมพ์ค้นหา ให้กรองตามชื่อร้าน (Store Name)
    if (_searchQuery.isNotEmpty) {
      query = query.where('storeName', isGreaterThanOrEqualTo: _searchQuery)
                   .where('storeName', isLessThanOrEqualTo: '$_searchQuery\uf8ff');
    }
    
    if (_selectedCategory != null) {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data?.docs ?? [];
        
        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text("No shops found in this category"),
            )
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final imageUrl = data['profileImage'] as String?;
            final name = data['storeName'] ?? "Unnamed Shop";
            final isOpen = data['isOpen'] ?? false;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: (imageUrl != null && imageUrl.isNotEmpty) ? NetworkImage(imageUrl) : null,
                  child: imageUrl == null ? const Icon(Icons.store) : null,
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(isOpen ? "Open" : "Closed", style: TextStyle(color: isOpen ? Colors.green : Colors.red)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // ไปยังหน้าร้านค้าของลูกค้า (ถ้ามี)
                },
              ),
            );
          },
        );
      },
    );
  }

  // --- ส่วนของ UI เดิม (Bottom Nav) ---

  Widget _buildGradientIcon(IconData icon, bool isSelected) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isSelected
              ? [Colors.grey[300]!, Colors.grey[900]!]
              : [const Color(0xFFFFD359), const Color(0xFFB26C3D), const Color(0xFF650620)],
        ).createShader(bounds);
      },
      child: Icon(icon, size: 32, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _getPages()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: _buildGradientIcon(Icons.shopping_bag, _selectedIndex == 0), label: ''),
          BottomNavigationBarItem(icon: _buildGradientIcon(Icons.shopping_cart, _selectedIndex == 1), label: ''),
          BottomNavigationBarItem(icon: _buildGradientIcon(Icons.list_alt, _selectedIndex == 2), label: ''),
          BottomNavigationBarItem(icon: _buildGradientIcon(Icons.person, _selectedIndex == 3), label: ''),
        ],
      ),
    );
  }
}