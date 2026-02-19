import 'image_selection_page.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'my_shop_page.dart';

class UserRegisterShopPage extends StatefulWidget {
  const UserRegisterShopPage({super.key});

  @override
  State<UserRegisterShopPage> createState() => _UserRegisterShopPageState();
}

class _UserRegisterShopPageState extends State<UserRegisterShopPage> {
  // เปลี่ยนชนิดตัวแปรเป็น dynamic เพื่อรองรับทั้ง XFile (รูปจริง) และ String (รูป Mock URL)
  dynamic _pickedImage; 
  
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = ['Food & Drink', 'Fashion', 'Electronics', 'Service', 'Other'];

  Future<void> _pickImage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ImageSelectionPage()),
    );
    
    // ตรวจสอบว่ามีค่าส่งกลับมาไหม
    if (result != null) {
      setState(() {
        _pickedImage = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Helper สำหรับแสดงรูป (รองรับทั้ง File และ Network)
    ImageProvider? imageProvider;
    if (_pickedImage is XFile) {
      imageProvider = kIsWeb 
          ? NetworkImage((_pickedImage as XFile).path) 
          : FileImage(File((_pickedImage as XFile).path)) as ImageProvider;
    } else if (_pickedImage is String) {
      imageProvider = NetworkImage(_pickedImage);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.close, size: 35, color: Colors.black)),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              // Profile Placeholder
              Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  image: imageProvider != null 
                    ? DecorationImage(image: imageProvider, fit: BoxFit.cover) 
                    : null,
                ),
                child: _pickedImage == null ? Icon(Icons.person, size: 100, color: Colors.grey.shade200) : null,
              ),
              const SizedBox(height: 20),
              
              // Attach Picture Button
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.file_upload_outlined, color: Colors.black),
                label: const Text("Attach Picture", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                ),
              ),
              if (_pickedImage != null)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("Image Selected "), Icon(Icons.check_circle_outline, size: 18)],
                  ),
                ),
              
              const SizedBox(height: 30),

              // Yellow Form Card
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Store Name"),
                    _buildInputField(_storeNameController, "Value"),
                    const SizedBox(height: 15),
                    _buildLabel("Shop Description"),
                    _buildInputField(_descController, "Value", maxLines: 4),
                    const SizedBox(height: 15),
                    _buildLabel("Telephone"),
                    _buildInputField(_phoneController, "Value", type: TextInputType.phone),
                    const SizedBox(height: 15),
                    _buildLabel("Category"),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCategory,
                          hint: const Text("Value", style: TextStyle(color: Colors.grey)),
                          items: _categories.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),

              // Build Button
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyShopPage(
                      storeName: _storeNameController.text,
                      description: _descController.text,
                      phone: _phoneController.text,
                      profileImage: _pickedImage, // ส่ง dynamic image ไป
                    )));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.grey)),
                  ),
                  child: const Text("Build", style: TextStyle(color: Colors.black, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 5, bottom: 5),
    child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
  );

  Widget _buildInputField(TextEditingController ctrl, String hint, {int maxLines = 1, TextInputType type = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: ctrl, maxLines: maxLines, keyboardType: type,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.all(15)),
      ),
    );
  }
}