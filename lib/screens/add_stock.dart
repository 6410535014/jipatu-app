import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddStockPage extends StatefulWidget {
  // รับข้อมูลเดิมมาแก้ไข (ถ้ามี)
  final Map<String, dynamic>? existingItem;

  const AddStockPage({super.key, this.existingItem});

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  
  XFile? _imageFile; 
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // ถ้ามีข้อมูลเดิม ให้ใส่ค่าเริ่มต้น
    _nameController = TextEditingController(text: widget.existingItem?['name'] ?? '');
    _descController = TextEditingController(text: widget.existingItem?['desc'] ?? '');
    _priceController = TextEditingController(text: widget.existingItem?['price'] ?? '');
    
    // โหลดรูปเดิม
    if (widget.existingItem?['image'] != null) {
      _imageFile = widget.existingItem!['image'];
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.existingItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Menu" : "Add Menu"),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200, 
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _imageFile != null 
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: kIsWeb
                          ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                          : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                        Text("แตะเพื่อเพิ่ม/แก้ไขรูป", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "ชื่อเมนู", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "ราคา", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: "รายละเอียด", border: OutlineInputBorder())),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: isEditing ? Colors.orange : Colors.green),
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    Navigator.pop(context, {
                      'name': _nameController.text,
                      'price': _priceController.text,
                      'desc': _descController.text,
                      'image': _imageFile,
                    });
                  }
                },
                child: Text(isEditing ? "Update Menu" : "Save Menu", style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}