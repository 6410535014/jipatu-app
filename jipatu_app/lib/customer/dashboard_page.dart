import 'package:flutter/material.dart';
import 'profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const Center(child: Text('Dashboard')),
    const Center(child: Text('Your Cart')),
    const Center(child: Text('Your Orders')),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildGradientIcon(IconData icon, bool isSelected) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isSelected
              ? [
                  Colors.grey[300]!,
                  Colors.grey[900]!,
                ]
              : [
                  const Color(0xFFFFD359),
                  const Color(0xFFB26C3D),
                  const Color(0xFF650620),
                ],
        ).createShader(bounds);
      },
      child: Icon(
        icon,
        size: 32,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: _buildGradientIcon(Icons.shopping_bag, _selectedIndex == 0),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildGradientIcon(Icons.shopping_cart, _selectedIndex == 1),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildGradientIcon(Icons.list_alt, _selectedIndex == 2),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildGradientIcon(Icons.person, _selectedIndex == 3),
            label: '',
          ),
        ],
      ),
    );
  }
}