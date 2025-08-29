import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isOtpSent = false; // Track OTP sent status

  final List<String> imgList = [
    'assets/images/image-1.jpg',
    'assets/images/image-2.jpg',
    'assets/images/image-3.jpg',
  ];

  void _handleSubmit() async {
    String email = _emailController.text;

    if (email.isEmpty) {
      _showDialog('Error', 'Please enter your email address.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/v1/beekeeper/fpassword'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        setState(() {
          _isOtpSent = true; // Set OTP sent status to true
        });
        _showDialog('OTP Sent', 'Check your email for the OTP.');
      } else {
        _showDialog('Error', 'Something went wrong. Please try again.');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showDialog('Error', 'Something went wrong. Please try again.');
    }
  }

  void _handleOtpSubmit() async {
    String email = _emailController.text;
    String otp = _otpController.text;
    String newPassword = _passwordController.text;

    if (otp.isEmpty || newPassword.isEmpty) {
      _showDialog('Error', 'Please enter OTP and new password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/v1/beekeeper/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body:
            json.encode({'email': email, 'otp': otp, 'password': newPassword}),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        _showDialog('Password Reset', 'Your password has been reset.',
            popTwice: true);
      } else {
        _showDialog('Error', 'Invalid OTP or something went wrong.');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showDialog('Error', 'Something went wrong. Please try again.');
    }
  }

  void _showDialog(String title, String message, {bool popTwice = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (popTwice) {
                  Navigator.of(context).pop();
                }
              },
              child:
                  const Text('OK', style: TextStyle(color: Color(0xFFFFB22C))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                ClipPath(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CarouselSlider(
                              items: imgList
                                  .map((item) => Image.asset(item,
                                      fit: BoxFit.cover,
                                      width: double.infinity))
                                  .toList(),
                              options: CarouselOptions(
                                height: 400,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 5),
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withAlpha(100),
                                      Colors.black.withAlpha(100),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/images/Logo.png',
                                      width: 150,
                                      height: 150,
                                    ),
                                    const SizedBox(height: 0),
                                    const Text(
                                      'BeeHive Manager',
                                      style: TextStyle(
                                        color: Color(0xFFFFB22C),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 340),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center, // Changed to start
                              children: [
  // Center-aligned title section
  const SizedBox(
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Reset Password',
          style: TextStyle(
            color: Color(0xFFFFB22C),
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Password reset option',
          style: TextStyle(
            color: Color(0xFFFFB22C),
            fontSize: 16,
          ),
        ),
      ],
    ),
  ),
  const SizedBox(height: 20),
  
  // Left-aligned email section
  const Align(
    alignment: Alignment.centerLeft,
    child: Text('Email',
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold)),
  ),
  const SizedBox(height: 12),
  Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(30),
      color: Colors.white,
    ),
    child: TextField(
      controller: _emailController,
      decoration: const InputDecoration(
        hintText: 'Enter your email',
        prefixIcon:
            Icon(Icons.email, color: Colors.grey),
        border: InputBorder.none,
        contentPadding:
            EdgeInsets.symmetric(vertical: 12),
            
      ),
      keyboardType: TextInputType.emailAddress,
    ),
  ),
],
                            ),
                          ),
                          if (_isOtpSent) ...[
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('OTP',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors.white,
                                    ),
                                    child: TextField(
                                      controller: _otpController,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter OTP',
                                        prefixIcon: Icon(Icons.lock,
                                            color: Colors.grey),
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('New Password',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors.white,
                                    ),
                                    child: TextField(
                                      controller: _passwordController,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter new password',
                                        prefixIcon: Icon(Icons.lock_outline,
                                            color: Colors.grey),
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      obscureText: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SizedBox(
                              width: 260,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : (_isOtpSent
                                        ? _handleOtpSubmit
                                        : _handleSubmit),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFFFFB22C), // Orange color
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 5.0,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      )
                                    : Text(
                                        _isOtpSent
                                            ? 'RESET PASSWORD'
                                            : 'SUBMIT',
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Navigate back to login
                            },
                            child: const Text('Back to Login',
                                style: TextStyle(
                                  color: Color(0xFFFFB22C), // Orange color
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF3A7D44)), // Green color
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Processing...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}