import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart'; // For input formatting

class GetEmailScreen extends StatefulWidget {
  const GetEmailScreen({super.key});

  @override
  State<GetEmailScreen> createState() => _GetEmailScreenState();
}

class _GetEmailScreenState extends State<GetEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isHovered = false;
  String? _errorText;

  // Color scheme
  final Color primaryColor = const Color(0xFFFFB22C);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF343A40);
  final Color secondaryTextColor = const Color(0xFF6C757D);

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {}); // Rebuild when focus changes
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<String?> _getStoredEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? beekeeperJson = prefs.getString('beekeeper');
    if (beekeeperJson != null) {
      final data = jsonDecode(beekeeperJson);
      return data['email'];
    }
    return null;
  }

  void _handleSubmit() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final enteredEmail = _emailController.text.trim();
    
    // Basic email validation
    if (enteredEmail.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorText = 'Please enter your email address';
      });
      return;
    }
    
    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(enteredEmail)) {
      setState(() {
        _isLoading = false;
        _errorText = 'Please enter a valid email address';
      });
      return;
    }

    final storedEmail = await _getStoredEmail();

    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    if (enteredEmail == storedEmail) {
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/updateBeekeeper', arguments: enteredEmail);
    } else {
      setState(() {
        _errorText = 'Entered email does not match our records';
      });
      // Haptic feedback for error
      HapticFeedback.heavyImpact();
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF343A40)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Verify Your Email', style: TextStyle(color: Color(0xFF343A40))),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header text
              const SizedBox(height: 20),
              const Text(
                'Email Verification',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFB22C),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please enter your registered email address to update your account details',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                 color: Color(0xFFFFB22C),
                  height: 1.5,
                ),
              ),
              
              // Lottie animation
              const SizedBox(height: 40),
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                padding: const EdgeInsets.all(16),
                child: Lottie.asset(
                  'assets/redy_bee.json',
                  fit: BoxFit.contain,
                ),
              ),
              
              // Email input card
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Email input field
                    TextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleSubmit(),
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: TextStyle(color: secondaryTextColor),
                        prefixIcon: Icon(Icons.email_rounded, color: _emailFocusNode.hasFocus ? primaryColor : secondaryTextColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          // ignore: deprecated_member_use
                          borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        errorText: _errorText,
                        errorStyle: const TextStyle(fontSize: 14),
                      ),
                      style: TextStyle(color: textColor, fontSize: 16),
                    ),
                    
                    // Submit button
                    const SizedBox(height: 24),
                    MouseRegion(
                      onEnter: (_) => setState(() => _isHovered = true),
                      onExit: (_) => setState(() => _isHovered = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: primaryColor,
                          boxShadow: _isHovered 
                            ? [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ]
                            : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _isLoading ? null : _handleSubmit,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Verify Email',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Help text
              const SizedBox(height: 32),
              Text(
                'Can\'t remember your email? Contact support',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}