import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'image_selection_page.dart';
import 'my_shop_page.dart';

class UserRegisterShopPage extends StatefulWidget {
  const UserRegisterShopPage({super.key});

  @override
  State<UserRegisterShopPage> createState() => _UserRegisterShopPageState();
}

class _UserRegisterShopPageState extends State<UserRegisterShopPage> {
  dynamic _pickedImage;
  bool _isLoading = false;

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
    if (result != null) {
      setState(() => _pickedImage = result);
    }
  }

  Future<void> _buildShop() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String? finalImageUrl;

      // 1. จัดการรูปภาพ
      if (_pickedImage != null) {
        if (_pickedImage is XFile) {
          // อัปโหลดไฟล์จริงไป Firebase Storage
          File file = File((_pickedImage as XFile).path);
          String fileName = 'shop_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          Reference ref = FirebaseStorage.instance.ref().child('shops/$fileName');
          
          await ref.putFile(file);
          finalImageUrl = await ref.getDownloadURL();
        } else if (_pickedImage is String) {
          // ใช้ URL ตรงๆ (กรณีเลือก Mockup)
          finalImageUrl = _pickedImage;
        }
      }

      // 2. บันทึกลง Firestore (users > uid > shop)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('shop')
          .add({
        'storeName': _storeNameController.text.trim(),
        'description': _descController.text.trim(),
        'phone': _phoneController.text.trim(),
        'category': _selectedCategory,
        'profileImage': finalImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MyShopPage(
          storeName: _storeNameController.text,
          description: _descController.text,
          phone: _phoneController.text,
          profileImage: finalImageUrl,
        )));
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_pickedImage is XFile) {
      imageProvider = kIsWeb ? NetworkImage((_pickedImage as XFile).path) : FileImage(File((_pickedImage as XFile).path)) as ImageProvider;
    } else if (_pickedImage is String) {
      imageProvider = NetworkImage(_pickedImage);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                // Profile Circle
                Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    image: imageProvider != null ? DecorationImage(image: imageProvider, fit: BoxFit.cover) : null,
                  ),
                  child: _pickedImage == null ? Icon(Icons.person, size: 100, color: Colors.grey.shade200) : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.file_upload_outlined, color: Colors.black),
                  label: const Text("Attach Picture", style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD54F)),
                ),
                const SizedBox(height: 30),
                // Form
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(color: const Color(0xFFFFD54F), borderRadius: BorderRadius.circular(30)),
                  child: Column(
                    children: [
                      _buildInputField(_storeNameController, "Store Name"),
                      const SizedBox(height: 15),
                      _buildInputField(_descController, "Description", maxLines: 3),
                      const SizedBox(height: 15),
                      _buildInputField(_phoneController, "Telephone", type: TextInputType.phone),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v),
                        decoration: const InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: _buildShop,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300),
                    child: const Text("Build", style: TextStyle(color: Colors.black, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String hint, {int maxLines = 1, TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl, maxLines: maxLines, keyboardType: type,
      decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
    );
  }
}