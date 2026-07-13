import 'package:flutter/material.dart';
import '../data/style.dart';
import '../services/auth_service.dart';
import 'home_nav.dart';
import 'loading_page.dart';
import '../widgets/app_modals.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameCont = TextEditingController(); // ADDED
  final emailCont = TextEditingController();
  final phoneCont = TextEditingController(); // ADDED
  final passCont = TextEditingController();
  final AuthService _auth = AuthService();

  void _handleSignup() async {
    String name = nameCont.text.trim(); // ADDED
    String email = emailCont.text.trim();
    String phone = phoneCont.text.trim(); // ADDED
    String pass = passCont.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || pass.isEmpty) {
      AppModals.showStatus(context: context, message: "FIELDS CANNOT BE EMPTY");
      return;
    }
    
    if (!email.contains('@') || !email.contains('.')) {
      AppModals.showStatus(context: context, message: "INVALID EMAIL FORMAT (@)");
      return;
    }

    if (pass.length < 6) {
      AppModals.showStatus(context: context, message: "PASSWORD TOO SHORT (MIN 6)");
      return;
    }

    try {
      // Pass all 4 fields to the auth service
      await _auth.signUp(email, pass, name, phone);
      if (mounted) {
        AppModals.showStatus(context: context, message: "STAFF REGISTERED!", isError: false);
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => const LoadingPage(message: "CREATING PROFILE...", nextPage: HomeNav())
        ));
      }
    } catch (e) {
      String errorMsg = "REGISTRATION FAILED";
      if (e.toString().contains('email-already-in-use')) {
        errorMsg = "EMAIL IS ALREADY REGISTERED";
      } else if (e.toString().contains('weak-password')) {
        errorMsg = "PASSWORD IS TOO WEAK";
      } else if (e.toString().contains('invalid-email')) {
        errorMsg = "BADLY FORMATTED EMAIL";
      }
      AppModals.showStatus(context: context, message: errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            width: double.infinity, 
            height: 208,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/logo.png'),
                alignment: Alignment(0.5, -2.0), 
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: AppColors.black, width: 5)),
            ),
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(30), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ORDERED: FULLNAME -> EMAIL -> CONTACT -> PASSWORD
            _inputField("FULL NAME", Icons.person_outline, nameCont),
            const SizedBox(height: 15),
            _inputField("EMAIL ADDRESS", Icons.mail_outline, emailCont, keyboard: TextInputType.emailAddress),
            const SizedBox(height: 15),
            _inputField("CONTACT NUMBER", Icons.phone_android_outlined, phoneCont, keyboard: TextInputType.phone),
            const SizedBox(height: 15),
            _inputField("PASSWORD", Icons.lock_outline, passCont, isPass: true),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _handleSignup, 
              child: Container(
                width: double.infinity, 
                padding: const EdgeInsets.all(18), 
                decoration: neoBox(color: AppColors.mintGreen), 
                child: const Center(child: Text("CREATE ACCOUNT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
              )
            ),
            const SizedBox(height: 15),
            Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("Already have an account? SIGN IN", style: TextStyle(color: Color.fromARGB(255, 78, 35, 235), fontWeight: FontWeight.bold)))),
          ]))
        ]),
      ),
    );
  }

  Widget _inputField(String l, IconData i, TextEditingController c, {bool isPass = false, TextInputType keyboard = TextInputType.text}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)), Container(margin: const EdgeInsets.only(top: 8), decoration: neoBox(radius: 12, color: Colors.white), child: TextField(controller: c, obscureText: isPass, keyboardType: keyboard, decoration: InputDecoration(prefixIcon: Icon(i, color: AppColors.gradientStart), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15))))]);
}