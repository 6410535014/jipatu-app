import 'package:flutter/material.dart';

class AddPaymentInfoPage extends StatefulWidget {
  final Map<String, String>? existingData; // รับข้อมูลเดิม

  const AddPaymentInfoPage({super.key, this.existingData});

  @override
  State<AddPaymentInfoPage> createState() => _AddPaymentInfoPageState();
}

class _AddPaymentInfoPageState extends State<AddPaymentInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bankCtrl;
  late TextEditingController _accNameCtrl;
  late TextEditingController _accNumCtrl;

  @override
  void initState() {
    super.initState();
    // ถ้ามีข้อมูลเดิม ให้ใส่ในช่องกรอกเลย
    _bankCtrl = TextEditingController(text: widget.existingData?['bankName'] ?? '');
    _accNameCtrl = TextEditingController(text: widget.existingData?['accountName'] ?? '');
    _accNumCtrl = TextEditingController(text: widget.existingData?['accountNumber'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add / Edit Payment")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _bankCtrl,
                decoration: const InputDecoration(labelText: "ฺBank Name", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Please enter the bank name" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _accNumCtrl,
                decoration: const InputDecoration(labelText: "Account Number", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Please enter the account number" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _accNameCtrl,
                decoration: const InputDecoration(labelText: "Bank Account Name", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Please enter the bank account name" : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // ส่งข้อมูลกลับไป
                      Navigator.pop(context, {
                        'bankName': _bankCtrl.text,
                        'accountNumber': _accNumCtrl.text,
                        'accountName': _accNameCtrl.text,
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text("Save", style: TextStyle(fontSize: 18)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}