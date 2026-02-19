import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddStockPage extends StatefulWidget {
  final Map<String, dynamic>? existingItem;
  const AddStockPage({super.key, this.existingItem});

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  bool _isSaving = false; // สำหรับแสดงสถานะการบันทึก
  
  XFile? _imageFile; 
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingItem?['name'] ?? '');
    _descController = TextEditingController(text: widget.existingItem?['desc'] ?? '');
    _priceController = TextEditingController(text: widget.existingItem?['price'] ?? '');
    
    if (widget.existingItem?['image'] != null) {
      _imageFile = widget.existingItem!['image'];
    }
  }

  // 2. ฟังก์ชันสำหรับบันทึกข้อมูลลง Firestore
  Future<void> _saveProductToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _nameController.text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      // ค้นหาเอกสารร้านค้าของผู้ใช้ใน users > uid > shop
      final shopSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('shop')
          .limit(1)
          .get();

      if (shopSnapshot.docs.isNotEmpty) {
        // อ้างอิงเอกสารร้านค้า
        DocumentReference shopRef = shopSnapshot.docs.first.reference;

        final productData = {
          'name': _nameController.text.trim(),
          'price': _priceController.text.trim(),
          'desc': _descController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (widget.existingItem != null && widget.existingItem!['id'] != null) {
          // กรณีแก้ไขสินค้าเดิม (ถ้าคุณส่ง id มาด้วยใน existingItem)
          await shopRef.collection('products').doc(widget.existingItem!['id']).update(productData);
        } else {
          // กรณีเพิ่มสินค้าใหม่
          productData['createdAt'] = FieldValue.serverTimestamp();
          await shopRef.collection('products').add(productData);
        }

        if (mounted) {
          Navigator.pop(context, true); // ส่งค่า true กลับไปเพื่อให้หน้าก่อนหน้า Refresh ข้อมูล
        }
      }
    } catch (e) {
      debugPrint("Error saving product: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.existingItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Menu" : "Add Menu"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD32F2F), Color(0xFFFFB300)],
            ),
          ),
        ),
      ),
      body: _isSaving 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ส่วนรูปภาพ (คุณสามารถลบทิ้งได้เลยหากไม่ต้องการใช้งานแล้ว)
                const Icon(Icons.inventory_2, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: "ชื่อสินค้า/เมนู", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "ราคา", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: _descController, decoration: const InputDecoration(labelText: "รายละเอียด", border: OutlineInputBorder())),
                const SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: isEditing ? Colors.orange : Colors.green),
                    onPressed: _isSaving ? null : _saveProductToFirestore, // เรียกฟังก์ชันบันทึก
                    child: Text(isEditing ? "Update Menu" : "Save Menu", style: const TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}