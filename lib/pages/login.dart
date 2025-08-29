import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required String title});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;
  String _errorMessage = "";
  String _passwordStrength = "";

  final List<String> imgList = [
    'assets/images/image-1.jpg',
    'assets/images/image-2.jpg',
    'assets/images/image-3.jpg',
  ];

  Future<void> _handleSubmit() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Please fill in both fields.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final response = await http.post(
        Uri.parse("http://localhost:3000/api/v1/beekeeper/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        //204 kiwwama content ekak na eka 200 karala balana
        // ignore: avoid_print
        //print('response body: ${response.body}');

        final responseData = jsonDecode(response.body);
        if (kDebugMode) {
          print(responseData);
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', responseData['token']);

        await prefs.setString('beekeeper', jsonEncode(responseData['data']));

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User logged in successfully')),
        );
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/dashboard');
        _usernameController.clear();
        _passwordController.clear();
      } else if (response.statusCode == 400) {
        setState(() {
          _errorMessage = 'User not registered. Please sign up.';
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not registered. Please sign up.')),
        );
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'Invalid password.';
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid password.')),
        );
      } else {
        setState(() {
          _errorMessage = 'You are deactivated.';
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are deactivated.')),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to login. Please try again.";
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to login. Please try again.')),
      );
    }
  }

  String _validatePassword(String password) {
    if (password.isEmpty) {
      return "Password cannot be empty";
    } else if (password.length < 8) {
      return "Password too short";
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "Password must contain an uppercase letter";
    } else if (!RegExp(r'[a-z]').hasMatch(password)) {
      return "Password must contain a lowercase letter";
    } else if (!RegExp(r'[0-9]').hasMatch(password)) {
      return "Password must contain a number";
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return "Password must contain a special character";
    } else {
      return "Strong";
    }
  }

  Widget _buildPasswordStrengthMeter(String strength) {
    Color color;
    String text;
    if (strength == "Password too short" ||
        strength == "Password cannot be empty") {
      color = Colors.red;
      text = "Weak";
    } else if (strength.contains("must contain")) {
      color = Colors.orange;
      text = "Medium";
    } else if (strength == "Strong") {
      color = const Color(0xFF3A7D44); // Green color from second code
      text = "Strong";
    } else {
      color = Colors.red;
      text = "Weak";
    }

    return Row(
      children: [
        Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LinearProgressIndicator(
            value:
                strength == "Strong" ? 1.0 : (strength == "Medium" ? 0.5 : 0.2),
            color: color,
            backgroundColor: Colors.grey[300],
          ),
        ),
      ],
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
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Username',
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
                                  controller: _usernameController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter username',
                                    prefixIcon:
                                        Icon(Icons.person, color: Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Password',
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
                                  obscureText: !_showPassword,
                                  onChanged: (password) {
                                    setState(() {
                                      _passwordStrength =
                                          _validatePassword(password);
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter password',
                                    prefixIcon: const Icon(Icons.lock,
                                        color: Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _showPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _showPassword = !_showPassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildPasswordStrengthMeter(_passwordStrength),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 1.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/fpassword');
                              },
                              child: const Text('Update Password?',
                                  style: TextStyle(
                                    color: Color(0xFFFFB22C), // Orange color
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: 260,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSubmit,
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : const Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
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
                        'Logging In...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 50),
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
