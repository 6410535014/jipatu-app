import 'image_selection_page.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditShopProfile extends StatefulWidget {
  final String? currentStoreName;
  final String? currentDesc;
  final String? currentPhone;
  final dynamic currentImage; // รองรับ dynamic

  const EditShopProfile({
    super.key, 
    this.currentStoreName, 
    this.currentDesc, 
    this.currentPhone, 
    this.currentImage
  });

  @override
  State<EditShopProfile> createState() => _EditShopProfileState();
}

class _EditShopProfileState extends State<EditShopProfile> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _phoneCtrl;
  dynamic _newImage;
  String? _selectedCategory = 'Food & Drink'; 
  final List<String> _categories = ['Food & Drink', 'Fashion', 'Electronics', 'Service', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentStoreName);
    _descCtrl = TextEditingController(text: widget.currentDesc);
    _phoneCtrl = TextEditingController(text: widget.currentPhone);
    _newImage = widget.currentImage;
  }

  Future<void> _pickImage() async {
    final selectedImage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ImageSelectionPage()),
    );
    if (selectedImage != null) {
      setState(() {
        _newImage = selectedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_newImage is XFile) {
      imageProvider = kIsWeb 
          ? NetworkImage((_newImage as XFile).path) 
          : FileImage(File((_newImage as XFile).path)) as ImageProvider;
    } else if (_newImage is String) {
      imageProvider = NetworkImage(_newImage);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 35, color: Colors.black),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              // 1. ส่วนรูปโปรไฟล์
              Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                  image: imageProvider != null 
                    ? DecorationImage(image: imageProvider, fit: BoxFit.cover) 
                    : null,
                ),
                child: _newImage == null 
                    ? Icon(Icons.person, size: 100, color: Colors.grey.shade200) 
                    : null,
              ),
              const SizedBox(height: 20),
              
              // 2. ปุ่ม Attach Picture
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
              const SizedBox(height: 30),

              // 3. Form
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
                    _buildInputField(_nameCtrl, "Enter store name"),
                    const SizedBox(height: 15),
                    _buildLabel("Shop Description"),
                    _buildInputField(_descCtrl, "Enter description", maxLines: 4),
                    const SizedBox(height: 15),
                    _buildLabel("Telephone"),
                    _buildInputField(_phoneCtrl, "0xx-xxx-xxxx", type: TextInputType.phone),
                    const SizedBox(height: 15),
                    _buildLabel("Category"),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCategory,
                          items: _categories.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),

              // 4. ปุ่ม Confirm Edit - ส่งข้อมูลกลับ
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // ส่งข้อมูลที่แก้แล้วกลับไป
                    Navigator.pop(context, {
                      'name': _nameCtrl.text,
                      'desc': _descCtrl.text,
                      'phone': _phoneCtrl.text,
                      'image': _newImage,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: const Text("Confirm Edit", style: TextStyle(color: Colors.black, fontSize: 18)),
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
    child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  );

  Widget _buildInputField(TextEditingController ctrl, String hint, {int maxLines = 1, TextInputType type = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: type,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.all(15)),
      ),
    );
  }
}