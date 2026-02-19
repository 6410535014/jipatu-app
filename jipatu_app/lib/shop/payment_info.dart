import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'add_payment_info.dart'; 

Map<String, dynamic>? globalPaymentData; 

class PaymentInfoPage extends StatefulWidget {
  const PaymentInfoPage({super.key});

  @override
  State<PaymentInfoPage> createState() => _PaymentInfoPageState();
}

class _PaymentInfoPageState extends State<PaymentInfoPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _navigateToAddPayment() async {
    // แปลงข้อมูลส่งไปแก้ไข (เฉพาะ Text)
    Map<String, String>? existingTextData;
    if (globalPaymentData != null) {
      existingTextData = {
        'bankName': globalPaymentData!['bankName'] ?? '',
        'accountNumber': globalPaymentData!['accountNumber'] ?? '',
        'accountName': globalPaymentData!['accountName'] ?? '',
      };
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPaymentInfoPage(existingData: existingTextData),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        // อัปเดตข้อมูล Text แต่เก็บรูป QR เดิมไว้
        XFile? currentQr = globalPaymentData?['qrImage'];
        globalPaymentData = {
          ...result,
          'qrImage': currentQr
        };
      });
    }
  }

  // ฟังก์ชันเลือก QR Code
  Future<void> _pickQRCode() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (globalPaymentData == null) globalPaymentData = {};
        globalPaymentData!['qrImage'] = image;
      });
    }
  }

  void _deletePaymentInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("ลบข้อมูล?"),
        content: const Text("คุณต้องการลบข้อมูลบัญชีธนาคารนี้ใช่หรือไม่?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ยกเลิก")),
          TextButton(
            onPressed: () {
              setState(() { globalPaymentData = {}; });
              Navigator.pop(ctx);
            },
            child: const Text("ลบ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasData = globalPaymentData != null && globalPaymentData!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Payment Info"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFFFB300)]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (hasData) _buildPaymentCard() else _buildEmptyState(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddPayment,
        backgroundColor: const Color(0xFFD32F2F),
        icon: Icon(hasData ? Icons.edit : Icons.add, color: Colors.white),
        label: Text(hasData ? "Edit Info" : "Add Account", style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 15),
          const Text("ยังไม่มีข้อมูลการชำระเงิน", style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 5),
          const Text("กดปุ่มด้านล่างเพื่อเพิ่มบัญชีธนาคาร", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    XFile? qrImage = globalPaymentData!['qrImage'];

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance, color: Colors.white70),
                    SizedBox(width: 10),
                    Text("Bank Account", style: TextStyle(color: Colors.white70)),
                  ],
                ),
                IconButton(
                  onPressed: _deletePaymentInfo,
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 30),
            
            Text(globalPaymentData!['bankName'] ?? "-", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(globalPaymentData!['accountNumber'] ?? "-", style: const TextStyle(color: Colors.white, fontSize: 26, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'Monospace')),
            const SizedBox(height: 20),
            Text("Name: ${globalPaymentData!['accountName'] ?? "-"}", style: const TextStyle(color: Colors.white, fontSize: 18)),

            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            
            // ส่วนแสดง QR Code
            Center(
              child: Column(
                children: [
                  const Text("Scan to Pay", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickQRCode,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: qrImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.network(qrImage.path, fit: BoxFit.cover)
                                  : Image.file(File(qrImage.path), fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.qr_code_scanner, size: 40, color: Colors.grey),
                                Text("แตะเพื่อเพิ่ม QR", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}