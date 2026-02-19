import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelectionPage extends StatefulWidget {
  const ImageSelectionPage({super.key});

  @override
  State<ImageSelectionPage> createState() => _ImageSelectionPageState();
}

class _ImageSelectionPageState extends State<ImageSelectionPage> {
  final List<String> _mockImages = List.generate(12, (index) => 'https://picsum.photos/200/200?random=$index');
  int? _selectedIndex;
  final ImagePicker _picker = ImagePicker();

  // เลือกรูปจากเครื่อง
  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (mounted) Navigator.pop(context, image);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
              image: _selectedIndex != null 
                ? DecorationImage(image: NetworkImage(_mockImages[_selectedIndex!]), fit: BoxFit.cover)
                : null,
            ),
            child: _selectedIndex == null 
                ? Icon(Icons.person, size: 100, color: Colors.grey.shade200) 
                : null,
          ),
          const SizedBox(height: 20),
          
          GestureDetector(
            onTap: _pickFromGallery,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library, color: Colors.black),
                  SizedBox(width: 10),
                  Text("Pick from Gallery", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          const Text("Or select avatar below", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),

          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD54F),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _mockImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: _selectedIndex == index 
                            ? Border.all(color: Colors.white, width: 3) 
                            : null,
                        image: DecorationImage(
                          image: NetworkImage(_mockImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(30.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedIndex != null) {
                    Navigator.pop(context, _mockImages[_selectedIndex!]);
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                child: const Text("Confirm Selection", style: TextStyle(color: Colors.black, fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}