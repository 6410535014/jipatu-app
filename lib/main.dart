import 'package:flutter/material.dart';
import 'screens/user_register_shop.dart'; 
import 'screens/my_shop_page.dart';
import 'screens/edit_shop_profile.dart';
import 'screens/image_selection_page.dart'; 
import 'screens/payment_info.dart';
import 'screens/add_payment_info.dart'; 
import 'screens/stock_main.dart';
import 'screens/add_stock.dart'; 

// --- 1. เพิ่ม Import หน้า Order (เพื่อให้รู้จักไฟล์นี้) ---
import 'screens/order_status.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zonda Shop',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.amber,
      ),
      home: const UserRegisterShopPage(), 
      
      routes: {
        '/register': (context) => const UserRegisterShopPage(),
        '/selection': (context) => const ImageSelectionPage(),
        '/payment': (context) => const PaymentInfoPage(),
        '/add_payment': (context) => const AddPaymentInfoPage(),
        
        // Stock Routes
        '/stock': (context) => const StockMainPage(),
        '/add_stock': (context) => const AddStockPage(),

        // --- 2. เพิ่ม Route สำหรับ Order (เผื่อใช้ในอนาคต) ---
        '/order_status': (context) => const OrderStatusPage(),
      },
    );
  }
}