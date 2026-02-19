// ใน lib/services/shop_service.dart
Future<void> addProduct({
  required String name,
  required double price,
  required String description,
  required String imageUrl,
  required String ownerUid, // ID ของคนขาย (โอม Login ไว้ให้แล้ว)
}) async {
  try {
    // ใช้ .doc().id เพื่อสร้าง pid ล่วงหน้า
    String pid = _db.collection('products').doc().id; 

    await _db.collection('products').doc(pid).set({
      'pid': pid, // กฎเหล็กข้อ 1
      'name': name,
      'price': price,
      'description': description, // กฎเหล็กข้อ 1
      'image_url': imageUrl, // กฎเหล็กข้อ 1 (ใช้ snake_case ตามตกลง)
      'owner_uid': ownerUid, // กฎเหล็กข้อ 1
      'createdAt': FieldValue.serverTimestamp(),
    });
    print("เพิ่มสินค้า $name สำเร็จแล้ว!");
  } catch (e) {
    print("Error: $e");
  }
}