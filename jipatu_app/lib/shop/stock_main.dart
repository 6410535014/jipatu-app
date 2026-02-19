import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 

// Import หน้า AddStock เพื่อให้เรียกใช้ Class ได้โดยตรง
import 'add_stock.dart'; 

// ตัวแปรกลางสำหรับเก็บข้อมูลสินค้า
List<Map<String, dynamic>> globalStockItems = []; 

class StockMainPage extends StatefulWidget {
  const StockMainPage({super.key});

  @override
  State<StockMainPage> createState() => _StockMainPageState();
}

class _StockMainPageState extends State<StockMainPage> {
  
  // ฟังก์ชันกดปุ่ม + (เพิ่มสินค้าใหม่)
  Future<void> _navigateToAddStock() async {
    // เปลี่ยนมาใช้ MaterialPageRoute เพื่อให้เหมือนกันทั้งระบบ
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStockPage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        globalStockItems.add(result);
      });
    }
  }

  // ฟังก์ชันกดที่การ์ดสินค้า (แก้ไขสินค้าเดิม)
  Future<void> _navigateToEditStock(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStockPage(existingItem: globalStockItems[index]), // ส่งข้อมูลเก่าไป
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        globalStockItems[index] = result; // อัปเดตข้อมูลที่ตำแหน่งเดิม
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: globalStockItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("ยังไม่มีสินค้า", style: TextStyle(color: Colors.grey)),
                  const Text("กดปุ่ม + ด้านล่างเพื่อเพิ่มเมนู", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: globalStockItems.length,
              itemBuilder: (context, index) {
                final item = globalStockItems[index];
                final XFile? imageFile = item['image'] as XFile?;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  // เพิ่ม InkWell เพื่อให้กดคลิกที่การ์ดได้
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _navigateToEditStock(index), // กดแล้วไปแก้ไข
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // รูปภาพ
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: kIsWeb
                                        ? Image.network(
                                            imageFile.path,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, stack) => const Icon(Icons.error),
                                          )
                                        : Image.file(
                                            File(imageFile.path),
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, stack) => const Icon(Icons.error),
                                          ),
                                  )
                                : const Icon(Icons.fastfood, color: Colors.grey, size: 30),
                          ),
                          const SizedBox(width: 15),
                          
                          // ข้อความ
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? "ไม่มีชื่อ",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "ราคา: ${item['price']} ฿",
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item['desc'] ?? "",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          
                          // ปุ่มลบ
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              // showDialog ยืนยันก่อนลบ (Optional)
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("ลบรายการ?"),
                                  content: const Text("คุณต้องการลบรายการนี้ใช่หรือไม่?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text("ยกเลิก"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          globalStockItems.removeAt(index);
                                        });
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text("ลบ", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddStock,
        backgroundColor: const Color(0xFFFFB300),
        child: const Icon(Icons.add, size: 30, color: Colors.black),
      ),
    );
  }
}