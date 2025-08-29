// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:lottie/lottie.dart';
//
// class ResetPassword extends StatefulWidget {
//   final String token;
//
//   const ResetPassword({super.key, required this.token});
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _ResetPasswordState createState() => _ResetPasswordState();
// }
//
// class _ResetPasswordState extends State<ResetPassword> {
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   bool _showPassword = false;
//   bool _showConfirmPassword = false;
//   bool _isLoading = false;
//   String _errorMessage = '';
//   String _passwordStrength = '';
//
//   String _validatePassword(String password) {
//     if (password.isEmpty) {
//       return "Password cannot be empty";
//     } else if (password.length < 8) {
//       return "Password too short";
//     } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
//       return "Password must contain an uppercase letter";
//     } else if (!RegExp(r'[a-z]').hasMatch(password)) {
//       return "Password must contain a lowercase letter";
//     } else if (!RegExp(r'[0-9]').hasMatch(password)) {
//       return "Password must contain a number";
//     } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
//       return "Password must contain a special character";
//     } else {
//       return "Strong";
//     }
//   }
//
//   Widget _buildPasswordStrengthMeter(String strength) {
//     Color color;
//     String text;
//     if (strength == "Password too short" || strength == "Password cannot be empty") {
//       color = Colors.red;
//       text = "Weak";
//     } else if (strength.contains("must contain")) {
//       color = Colors.orange;
//       text = "Medium";
//     } else if (strength == "Strong") {
//       color = Colors.green;
//       text = "Strong";
//     } else {
//       color = Colors.red;
//       text = "Weak";
//     }
//
//     return Row(
//       children: [
//         Text(
//           text,
//           style: TextStyle(color: color, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: LinearProgressIndicator(
//             value: strength == "Strong"
//                 ? 1.0
//                 : (strength == "Medium" ? 0.5 : 0.2),
//             color: color,
//             backgroundColor: Colors.grey[300],
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _handleSubmit() async {
//     String password = _passwordController.text;
//     String confirmPassword = _confirmPasswordController.text;
//
//     if (password != confirmPassword) {
//       setState(() {
//         _errorMessage = "Passwords do not match";
//       });
//       return;
//     } else if (_passwordStrength != "Strong") {
//       setState(() {
//         _errorMessage = "Password is not strong enough";
//       });
//       return;
//     } else {
//       setState(() {
//         _errorMessage = "";
//         _isLoading = true;
//       });
//     }
//
//     final response = await http.post(
//       Uri.parse('http://localhost:3000/api/v1/passenger/rpassword/${widget.token}'),
//       body: json.encode({'password': password}),
//       headers: {'Content-Type': 'application/json'},
//     );
//
//     if (response.statusCode == 200) {
//       //Map<String, dynamic> data = json.decode(response.body);
//       //if (data['status']) {
//         showDialog(
//           // ignore: use_build_context_synchronously
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Password Reset'),
//               content: const Text('Password reset successfully'),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     Navigator.of(context).pop(); // Pop twice to go back to login screen
//                   },
//                   child: const Text('OK'),
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     else {
//       setState(() {
//         _errorMessage = 'Error: ${response.reasonPhrase}';
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Reset Password'),
//         backgroundColor: const Color(0xFF6C63FF),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF6C63FF), Color(0xFFB39DDB)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20.0),
//             child: Card(
//               elevation: 10.0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.0),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     /*Center(
//                       child: Image.asset(
//                         'assets/logo.jpg',
//                         height: 150,
//                         width: 150,
//                       ),
//                     ),*/
//                      Center(
//               child: Lottie.asset(
//                 'assets/reset_password_animation.json', // Path to your Lottie animation asset
//                 height: 300, // Adjust the height as needed
//                 width: 300,  // Adjust the width as needed
//               ),
//             ),
//                     const SizedBox(height: 20.0),
//                     const Center(
//                       child: Text(
//                         'Reset Password',
//                         style: TextStyle(
//                           fontSize: 24.0,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF6C63FF),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10.0),
//                     const Center(
//                       child: Text(
//                         'Add new password',
//                         style: TextStyle(
//                           fontSize: 16.0,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20.0),
//                     TextField(
//                       controller: _passwordController,
//                       obscureText: !_showPassword,
//                       onChanged: (password) {
//                         setState(() {
//                           _passwordStrength = _validatePassword(password);
//                         });
//                       },
//                       decoration: InputDecoration(
//                         labelText: 'Password',
//                         filled: true,
//                         fillColor: Colors.grey[200],
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15.0),
//                           borderSide: BorderSide.none,
//                         ),
//                         prefixIcon: const Icon(Icons.lock, color: Color(0xFF6C63FF)),
//                         suffixIcon: IconButton(
//                           icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
//                           onPressed: () {
//                             setState(() {
//                               _showPassword = !_showPassword;
//                             });
//                           },
//                         ),
//                       ),
//                       style: const TextStyle(fontSize: 18.0),
//                     ),
//                     const SizedBox(height: 10.0),
//                     _buildPasswordStrengthMeter(_passwordStrength),
//                     const SizedBox(height: 10.0),
//                     TextField(
//                       controller: _confirmPasswordController,
//                       obscureText: !_showConfirmPassword,
//                       decoration: InputDecoration(
//                         labelText: 'Confirm Password',
//                         filled: true,
//                         fillColor: Colors.grey[200],
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15.0),
//                           borderSide: BorderSide.none,
//                         ),
//                         prefixIcon: const Icon(Icons.lock, color: Color(0xFF6C63FF)),
//                         suffixIcon: IconButton(
//                           icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
//                           onPressed: () {
//                             setState(() {
//                               _showConfirmPassword = !_showConfirmPassword;
//                             });
//                           },
//                         ),
//                       ),
//                       style: const TextStyle(fontSize: 18.0),
//                     ),
//                     if (_errorMessage.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Center(
//                           child: Text(
//                             _errorMessage,
//                             style: const TextStyle(color: Colors.red),
//                           ),
//                         ),
//                       ),
//                     const SizedBox(height: 20.0),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _handleSubmit,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF6C63FF),
//                           padding: const EdgeInsets.symmetric(vertical: 15.0),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15.0),
//                           ),
//                           elevation: 5.0,
//                           shadowColor: const Color(0xFF6C63FF).withOpacity(0.5),
//                         ),
//                         child: _isLoading
//                             ? const CircularProgressIndicator(
//                                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                               )
//                             : const Text(
//                                 'RESET',
//                                 style: TextStyle(
//                                   fontSize: 18.0,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
