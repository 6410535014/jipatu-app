import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // พื้นหลัง
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFED158),
              Color(0xFFFF5757),
              Color(0xFF650620),
            ],
          ),
          // ลายพื้นหลัง
          image: DecorationImage(
            image: AssetImage('assets/images/marble.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.12), // ความจางของลาย
              BlendMode.dstATop, // โหมดการผสมสี
            ),
          ),
        ),


        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                SizedBox(height: 100),
                // โลโก้
                Text(
                  'JIPATU',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                // รูปปลา
                Transform.translate(
                    offset: Offset(0, -70),
                    child: Image.asset('assets/images/patu2.png',width: 250,fit: BoxFit.contain,),
                ),

                Transform.translate(
                  offset: Offset(0, -100),
                  child: Column(
                    children: [
                      // input
                      buildInputLabel("Username"),
                      buildTextField("Value"),

                      SizedBox(height: 20),

                      buildInputLabel("Password"),
                      buildTextField("Value", isPassword: true),

                      SizedBox(height: 30),

                      // ปุ่มกด
                      buildActionButton("Sign In", onPressed: () {}),
                      SizedBox(height: 15),
                      buildActionButton("Register", onPressed: () {}, textColor: Colors.grey,),

                      SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 100),
                Text("@Thammasat", style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
        ),
      ),
    );
  }

  // Helper Label
  Widget buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  // Helper TextField
  Widget buildTextField(String hint, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  // Helper ปุ่ม
  Widget buildActionButton(String text, {VoidCallback? onPressed, Color textColor = Colors.white}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: textColor, fontSize: 18)),
      ),
    );
  }
}