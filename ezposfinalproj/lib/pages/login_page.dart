import 'package:flutter/material.dart';
import '../data/style.dart';
import '../services/auth_service.dart';
import 'loading_page.dart';
import 'home_nav.dart';
import 'signup_page.dart';
import '../widgets/app_modals.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCont = TextEditingController();
  final passCont = TextEditingController();
  final AuthService _auth = AuthService();

  // Animation States
  bool _isSignInPressed = false;
  bool _isGooglePressed = false;

  void _handleLogin() async {
    String email = emailCont.text.trim();
    String pass = passCont.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      AppModals.showStatus(context: context, message: "PLEASE FILL ALL FIELDS");
      return;
    }
    try {
      await _auth.login(email, pass);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => const LoadingPage(message: "ACCESS GRANTED", nextPage: HomeNav())
        ));
      }
    } catch (e) {
      String errorMsg = "LOGIN FAILED";
      String errStr = e.toString().toLowerCase();
      if (errStr.contains('invalid-email')) {
        errorMsg = "INVALID CREDENTIALS";
      } else if (errStr.contains('user-not-found') || errStr.contains('wrong-password')) errorMsg = "WRONG USERNAME OR PASSWORD";
      AppModals.showStatus(context: context, message: errorMsg);
    }
  }

  void _handleGoogle() async {
    try {
      final res = await _auth.signInWithGoogle();
      
      if (res == null) {
        // User canceled the Google Sign-in popup, do nothing.
        return; 
      }

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => const LoadingPage(message: "GOOGLE SIGNING IN...", nextPage: HomeNav())
        ));
      }
    } catch (e) {
      AppModals.showStatus(context: context, message: "GOOGLE SIGN IN FAILED");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            width: double.infinity, height: 208, 
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/logo.png'), alignment: Alignment(0.5, -2.0), fit: BoxFit.cover),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: AppColors.black, width: 5)),
            ),
          ),
          Padding(padding: const EdgeInsets.all(30), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _inputField("EMAIL", Icons.email_outlined, emailCont),
            const SizedBox(height: 20),
            _inputField("PASSWORD", Icons.lock_outline, passCont, isPass: true),
            const SizedBox(height: 30),
            
            // SIGN IN BUTTON WITH ANIMATION
            GestureDetector(
              onTapDown: (_) => setState(() => _isSignInPressed = true),
              onTapUp: (_) => setState(() => _isSignInPressed = false),
              onTapCancel: () => setState(() => _isSignInPressed = false),
              onTap: _handleLogin, 
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(18), 
                decoration: neoBox(color: _isSignInPressed ? const Color.fromARGB(255, 18, 90, 180) : const Color.fromARGB(255, 24, 119, 242), shadow: _isSignInPressed ? 1 : 4), 
                child: const Center(child: Text("Sign In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
              )
            ),
            
            const SizedBox(height: 15),
            
            // GOOGLE BUTTON WITH ANIMATION
            GestureDetector(
              onTapDown: (_) => setState(() => _isGooglePressed = true),
              onTapUp: (_) => setState(() => _isGooglePressed = false),
              onTapCancel: () => setState(() => _isGooglePressed = false),
              onTap: _handleGoogle, 
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(15), 
                decoration: neoBox(color: _isGooglePressed ? Colors.grey[200]! : Colors.white, shadow: _isGooglePressed ? 1 : 4), 
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Image.asset('assets/googlelogo.png', height:24, width:24, fit: BoxFit.contain), 
                  const SizedBox(width: 10), 
                  const Text("Google Sign-in", style: TextStyle(fontWeight: FontWeight.bold))
                ])
              )
            ),
            
            const SizedBox(height: 20),
            Center(child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage())), child: const Text("Don't have an account? SIGN UP", style: TextStyle(color: Color.fromARGB(255, 78, 35, 235), fontWeight: FontWeight.bold, fontSize: 12)))),
          ]))
        ]),
      ),
    );
  }

  Widget _inputField(String l, IconData i, TextEditingController c, {bool isPass = false}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), Container(margin: const EdgeInsets.only(top: 8), decoration: neoBox(radius: 10), child: TextField(controller: c, obscureText: isPass, decoration: InputDecoration(prefixIcon: Icon(i, color: AppColors.gradientStart), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15))))]);
}