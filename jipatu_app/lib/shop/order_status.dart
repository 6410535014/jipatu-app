import 'package:flutter/material.dart';

// --- หน้าหลัก: Order Status (รายการออเดอร์) ---
class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  // จำลองข้อมูลออเดอร์ที่เข้ามา (Mock Data)
  List<Map<String, dynamic>> orders = [
    {
      'id': '123456',
      'menu': 'Set A: ไก่ทอดกรอบ',
      'customer': 'Somchai Jaidee',
      'time': '12 JAN 2026 14:59',
      'status': 'Waiting...',
      'options': 'เผ็ดน้อย, ไม่ใส่ผัก',
      'note': '-',
      'qty': 1,
      'price': 99,
    },
    // ลองเพิ่มข้อมูลจำลองอีกอัน
    {
      'id': '123457',
      'menu': 'Set B: เบอร์เกอร์หมู',
      'customer': 'Manee Meerate',
      'time': '12 JAN 2026 15:05',
      'status': 'Waiting...',
      'options': 'เพิ่มชีส',
      'note': 'ซอสเยอะๆ',
      'qty': 2,
      'price': 159,
    },
  ];

  // ฟังก์ชันลบออเดอร์เมื่อทำเสร็จแล้ว
  void _completeOrder(String id) {
    setState(() {
      orders.removeWhere((item) => item['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Order Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
        centerTitle: true,
        leading: IconButton( // ปุ่มย้อนกลับ
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD32F2F), Color(0xFFFFB300)],
            ),
          ),
        ),
      ),
      
      body: orders.isEmpty
          ? _buildEmptyState() // หน้าว่างเมื่อไม่มีออเดอร์
          : ListView.builder(  // รายการออเดอร์
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderItem(orders[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("No pending orders", style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // รูปภาพอาหาร (Placeholder)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fastfood, size: 40, color: Colors.orange),
                ),
                const SizedBox(width: 15),
                // รายละเอียด
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['menu'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Order #${item['id']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text("By ${item['customer']}", style: const TextStyle(fontSize: 12)),
                      Text("Time: ${item['time']}", style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _goToDetail(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF66BB6A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Receive Order", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _goToDetail(item),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Detail >", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _goToDetail(Map<String, dynamic> item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderDetailPage(orderData: item)),
    );

    if (result == 'completed') {
      _completeOrder(item['id']);
    }
  }
}

// --- หน้า 2: Order Detail ---
class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> orderData;
  const OrderDetailPage({super.key, required this.orderData});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool isCooked = false;
  bool isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFFFB300)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // การ์ดรายละเอียด
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order: ${widget.orderData['id']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                      Text("Customer: ${widget.orderData['customer']}", style: const TextStyle(color: Colors.grey)),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text("• ${widget.orderData['menu']}", style: const TextStyle(fontWeight: FontWeight.bold))),
                          Text("x ${widget.orderData['qty']}"),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text("Option: ${widget.orderData['options']}", style: TextStyle(color: Colors.grey[700])),
                      Text("Note: ${widget.orderData['note']}", style: TextStyle(color: Colors.red[400])),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Checkbox
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: const Text("Cooked (ทำเสร็จแล้ว)", style: TextStyle(fontWeight: FontWeight.bold)),
                        value: isCooked,
                        activeColor: Colors.green,
                        onChanged: (val) => setState(() => isCooked = val!),
                      ),
                      CheckboxListTile(
                        title: const Text("Sending (กำลังส่ง)", style: TextStyle(fontWeight: FontWeight.bold)),
                        value: isSending,
                        activeColor: Colors.green,
                        onChanged: (val) => setState(() => isSending = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // ปุ่ม Complete
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: (isCooked && isSending) 
                        ? () => Navigator.pop(context, 'completed') 
                        : null,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text("Complete Order", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}