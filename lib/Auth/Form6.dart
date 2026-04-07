import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:EcoShine24/Auth/signup.dart';
import 'package:EcoShine24/Auth/signin.dart';
import 'package:EcoShine24/Auth/widgets/responsive_ui.dart';
import 'package:EcoShine24/grocery/General/AppConstant.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/phone_number_utils.dart';

class Form6 extends StatefulWidget {
  final String? initialMobile;

  const Form6({Key? key, this.initialMobile}) : super(key: key);

  @override
  _Form6State createState() => _Form6State();
}

class _Form6State extends State<Form6> with TickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String result = "";
  String currentText = "";
  bool isOtpSent = false;
  bool isLoading = false;
  bool isVerifying = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  double? _height;
  double? _width;
  double? _pixelRatio;
  bool _large = false;
  bool _medium = false;

  @override
  void initState() {
    super.initState();

    // Pre-fill phone number if provided
    if (widget.initialMobile != null && widget.initialMobile!.isNotEmpty) {
      phoneController.text = widget.initialMobile!;
    }

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  // Country selection removed; always use plain mobile number

  Future<void> sendOtp() async {
    if (!PhoneNumberUtils.isValidMobile(phoneController.text)) {
      _showToast("Please enter a valid 10-digit mobile number");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Make actual API call to step1.php
      var map = new Map<String, dynamic>();
      map['shop_id'] = GroceryAppConstant.Shop_id;
      map['name'] = "User"; // Default name as per API spec
      map['mobile'] = phoneController.text;

      final response = await http.post(
        Uri.parse(GroceryAppConstant.base_url + 'api/step1.php'),
        body: map,
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);

        // Check if success is true before proceeding
        if (jsonBody['success'] == "true") {
          setState(() {
            isOtpSent = true;
            isLoading = false;
          });

          _showToast(jsonBody['message'] ?? "OTP sent successfully");
        } else {
          // Show error message from API
          setState(() {
            isLoading = false;
          });
          _showToast(jsonBody['message'] ?? "Failed to send OTP");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _showToast("Network error. Please try again.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showToast("Failed to send OTP. Please try again.");
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.length != 5) {
      _showToast("Please enter a valid 5-digit OTP");
      return;
    }

    setState(() {
      isVerifying = true;
    });

    try {
      // Make actual API call to step2.php
      var map = new Map<String, dynamic>();
      map['shop_id'] = GroceryAppConstant.Shop_id;
      map['otp'] = otpController.text;
      map['mobile'] = phoneController.text;

      final response = await http.post(
        Uri.parse(GroceryAppConstant.base_url + 'api/step2.php'),
        body: map,
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);

        // Check if success is true before proceeding
        if (jsonBody['success'] == "true") {
          setState(() {
            isVerifying = false;
          });

          _showToast(jsonBody['message'] ?? "OTP verified successfully");

          // Save mobile number to SharedPreferences for signup form
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setString("temp_mobile", phoneController.text);

          // Navigate to signup form (step 3) to collect user details
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignUpScreen()),
          );
        } else {
          // Show error message from API
          setState(() {
            isVerifying = false;
          });
          _showToast(jsonBody['message'] ?? "Invalid OTP");
        }
      } else {
        setState(() {
          isVerifying = false;
        });
        _showToast("Network error. Please try again.");
      }
    } catch (e) {
      setState(() {
        isVerifying = false;
      });
      _showToast("Invalid OTP. Please try again.");
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: GroceryAppColors.tela,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width!, _pixelRatio!);
    _medium = ResponsiveWidget.isScreenMedium(_width!, _pixelRatio!);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Top section with gradient background
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      GroceryAppColors.tela,
                      GroceryAppColors.tela1,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative elements
                    Positioned(
                      top: -30,
                      right: -40,
                      child: AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value * 0.2,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -50,
                      child: AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value * 0.15,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Content
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Back button
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_back_ios_new,
                                          color: Colors.white, size: 18),
                                      onPressed: () => Navigator.pop(context),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                // Logo and brand section
                                Container(
                                  padding: EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 25,
                                        offset: Offset(0, 8),
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isOtpSent
                                        ? Icons.verified_user
                                        : Icons.app_registration,
                                    size: 48,
                                    color: GroceryAppColors.tela,
                                  ),
                                ),
                                SizedBox(height: 32),
                                Text(
                                  isOtpSent ? "Verify OTP" : "Create Account",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  isOtpSent
                                      ? "Enter the 5-digit code sent to\n${phoneController.text}"
                                      : "Register your mobile number to get\nstarted with our services",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.95),
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom section with form
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      // Form title
                      Text(
                        isOtpSent ? "Verification Code" : "Mobile Verification",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: GroceryAppColors.tela,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        isOtpSent
                            ? "Please enter the 5-digit verification code"
                            : "We'll send you a verification code",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 28),

                      if (!isOtpSent) ...[
                        // Phone number input
                        Text(
                          "Mobile Number",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildModernTextField(
                          controller: phoneController,
                          hintText: "Enter your 10-digit mobile number",
                          prefixIcon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                        ),
                        SizedBox(height: 32),
                        // Send OTP button
                        _buildModernButton(
                          onPressed: sendOtp,
                          text: "SEND VERIFICATION CODE",
                          isLoading: isLoading,
                        ),
                        SizedBox(height: 24),
                        _buildOrDivider(),
                      ] else ...[
                        // OTP input with modern design
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: PinCodeTextField(
                            appContext: context,
                            length: 5,
                            controller: otpController,
                            keyboardType: TextInputType.number,
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(14),
                              fieldHeight: 58,
                              fieldWidth: 52,
                              activeFillColor:
                                  GroceryAppColors.tela.withOpacity(0.08),
                              inactiveFillColor: Colors.white,
                              selectedFillColor:
                                  GroceryAppColors.tela.withOpacity(0.08),
                              activeColor: GroceryAppColors.tela,
                              inactiveColor: Colors.grey[300]!,
                              selectedColor: GroceryAppColors.tela,
                              borderWidth: 2,
                            ),
                            animationDuration: Duration(milliseconds: 300),
                            enableActiveFill: true,
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: GroceryAppColors.tela,
                            ),
                            onChanged: (value) {
                              setState(() {
                                currentText = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 22),
                        // Resend OTP option
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Didn't receive the code?",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isOtpSent = false;
                                    otpController.clear();
                                  });
                                },
                                child: Text(
                                  "Resend",
                                  style: TextStyle(
                                    color: GroceryAppColors.tela,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 28),
                        // Verify button
                        _buildModernButton(
                          onPressed: verifyOtp,
                          text: "VERIFY & CONTINUE",
                          isLoading: isVerifying,
                        ),
                        SizedBox(height: 24),
                        _buildOrDivider(),
                      ],

                      SizedBox(height: 24),
                      // Back to sign in
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInPage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: GroceryAppColors.tela, width: 2),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: GroceryAppColors.tela.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  color: GroceryAppColors.tela,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Back to Sign In",
                                  style: TextStyle(
                                    color: GroceryAppColors.tela,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: GroceryAppColors.tela.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: GroceryAppColors.tela.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: keyboardType == TextInputType.number
            ? PhoneNumberUtils.inputFormatters
            : null,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 15,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: GroceryAppColors.tela,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          counterText: "",
        ),
        onChanged: (value) {
          setState(() {
            result = value;
          });
        },
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              "OR",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildModernButton({
    required VoidCallback onPressed,
    required String text,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GroceryAppColors.tela,
            GroceryAppColors.tela1,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: GroceryAppColors.tela.withOpacity(0.3),
            blurRadius: 16,
            offset: Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}

// Placeholder for actual signup form
class SignUpForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complete Registration"),
        backgroundColor: Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green,
              ),
              SizedBox(height: 20),
              Text(
                "Phone Verified Successfully!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Please complete your profile information",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignInPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "Continue to Sign In",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
