import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:EcoShine24/Auth/forgetPassword.dart';
import 'package:EcoShine24/Auth/widgets/responsive_ui.dart';
import 'package:EcoShine24/grocery/General/AppConstant.dart';
import 'package:EcoShine24/grocery/General/Home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Form6.dart';
import '../utils/phone_number_utils.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Colors.white, // White background
        body: SignInScreen(),
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  double? _height;
  double? _width;
  double? _pixelRatio;
  bool _large = false, flag = false;
  bool _medium = false;
  bool _obscurePassword = true;

  // Login design variables
  int? loginDesign;
  bool isLoadingDesign = true;

  // Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  // OTP related variables
  bool isOtpSent = false;
  bool isOtpLogin = false;

  GlobalKey<FormState> _key = GlobalKey();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

    // Check login design when screen loads
    _checkLoginDesign();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    nameController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.dispose();
  }

  // Check login design from API
  Future<void> _checkLoginDesign() async {
    try {
      // Use GET method directly since that's what your API expects
      http.Response response;

      try {
        final uri = Uri.parse(GroceryAppConstant.base_url + 'api/cp.php')
            .replace(queryParameters: {
          'shop_id': GroceryAppConstant.Shop_id.toString(),
        });

        response = await http.get(uri).timeout(Duration(seconds: 10));
      } catch (e) {
        throw e;
      }

      if (response.statusCode == 200) {
        // Parse JSON response
        try {
          final jsonBody = json.decode(response.body);

          // Check all possible field names for login design
          String? designValue;
          if (jsonBody['loginDesign'] != null) {
            designValue = jsonBody['loginDesign'].toString();
          } else if (jsonBody['login_design'] != null) {
            designValue = jsonBody['login_design'].toString();
          } else if (jsonBody['logindesign'] != null) {
            designValue = jsonBody['logindesign'].toString();
          }

          if (designValue != null) {
            final parsedDesign = int.tryParse(designValue);

            setState(() {
              loginDesign = parsedDesign ?? 1;
              isOtpLogin = loginDesign == 4;
              isLoadingDesign = false;
            });

            print(
                "Login Design: $loginDesign, OTP Login: $isOtpLogin"); // Debug log
          } else {
            setState(() {
              loginDesign = 1;
              isOtpLogin = loginDesign == 4; // Use consistent logic
              isLoadingDesign = false;
            });

            print(
                "Login Design (fallback): $loginDesign, OTP Login: $isOtpLogin"); // Debug log
          }
        } catch (jsonError) {
          // Check if it's the specific error response from your API
          if (response.body.contains('What are you looking for')) {
            // For testing purposes, you can manually set the login design here
            // Remove this in production once your API is fixed
            setState(() {
              loginDesign = 4; // Force OTP login for testing
              isOtpLogin = loginDesign == 4; // Use consistent logic
              isLoadingDesign = false;
            });
          } else {
            // Fallback to password login
            setState(() {
              loginDesign = 1;
              isOtpLogin = loginDesign == 4; // Use consistent logic
              isLoadingDesign = false;
            });
          }
        }
      } else {
        setState(() {
          loginDesign = 1; // Default to password login
          isOtpLogin = loginDesign == 4; // Use consistent logic
          isLoadingDesign = false;
        });
      }
    } catch (e) {
      setState(() {
        loginDesign = 1; // Default to password login
        isOtpLogin = loginDesign == 4; // Use consistent logic
        isLoadingDesign = false;
      });
    }
  }

  // Send OTP for login
  Future<void> _sendLoginOtp() async {
    if (nameController.text.length != 10) {
      _showLongToast("Please enter a valid Mobile Number");
      return;
    }

    setState(() {
      flag = true;
    });

    try {
      var map = new Map<String, dynamic>();
      map['mobile'] = nameController.text;
      map['xkey'] = GroceryAppConstant.API_KEY;

      final response = await http.post(
        Uri.parse(GroceryAppConstant.base_url + 'api/send_otp.php'),
        body: map,
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        print("Send OTP Response: $jsonBody"); // Debug log

        if (jsonBody['success'] == "true") {
          setState(() {
            isOtpSent = true;
            flag = false;
          });
          _showLongToast("OTP sent successfully");
        } else {
          // Check if user is not registered and auto-start registration
          String message = jsonBody['message'] ?? "Failed to send OTP";
          if (message.contains("Your Mobile or Username is invalid")) {
            _showLongToast("Mobile not registered. Starting registration...");
            _startAutoRegistration();
          } else {
            _showLongToast(message);
            setState(() {
              flag = false;
            });
          }
        }
      } else {
        _showLongToast("Network error. Please try again.");
        setState(() {
          flag = false;
        });
      }
    } catch (e) {
      _showLongToast("Error: $e");
      setState(() {
        flag = false;
      });
    }
  }

  // Login with OTP
  Future<void> _loginWithOtp() async {
    if (otpController.text.isEmpty) {
      _showLongToast("Please enter OTP");
      return;
    }

    setState(() {
      flag = true;
    });

    // This is normal login flow - verify OTP for login
    await _verifyLoginOtp();
  }

  // Verify OTP for login flow
  Future<void> _verifyLoginOtp() async {
    try {
      var map = new Map<String, dynamic>();
      map['shop_id'] = GroceryAppConstant.Shop_id; // Add missing shop_id
      map['mobile'] = nameController.text;
      map['password'] = otpController.text + '_OTP'; // OTP with _OTP suffix
      map['xkey'] = GroceryAppConstant.API_KEY;

      final response = await http.post(
        Uri.parse(GroceryAppConstant.base_url + 'api/login.php'),
        body: map,
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        print("OTP Login Response: $jsonBody"); // Debug log

        if (jsonBody['success'] == "true") {
          // Handle successful login
          _handleSuccessfulLogin(jsonBody);
        } else {
          String errorMessage = jsonBody['message'] ?? "Login failed";
          _showLongToast(errorMessage);
          setState(() {
            flag = false;
          });
        }
      } else {
        _showLongToast("Network error. Please try again.");
        setState(() {
          flag = false;
        });
      }
    } catch (e) {
      _showLongToast("Error: $e");
      setState(() {
        flag = false;
      });
    }
  }

  // Auto-start registration when user is not found
  Future<void> _startAutoRegistration() async {
    setState(() {
      flag = false;
    });

    _showLongToast("Redirecting to registration...");

    // Navigate directly to Form6 for complete registration flow with pre-filled mobile
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Form6(initialMobile: nameController.text)),
    );
  }

  // Handle successful login (common for both methods)
  void _handleSuccessfulLogin(Map<String, dynamic> userData) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    setState(() {
      flag = false;
    });

    try {
      // Set user data in SharedPreferences with null safety
      pref.setString("email", userData['email']?.toString() ?? "");
      pref.setString("name", userData['name']?.toString() ?? "");
      pref.setString("city", userData['city']?.toString() ?? "");
      pref.setString("address", userData['address']?.toString() ?? "");
      pref.setString("sex", userData['sex']?.toString() ?? "");
      pref.setString(
          "mobile",
          userData['username']?.toString() ??
              userData['mobile']?.toString() ??
              "");
      pref.setString("pin",
          userData['pincode']?.toString() ?? userData['pin']?.toString() ?? "");
      pref.setString(
          "user_id",
          userData['user_id']?.toString() ??
              userData['userId']?.toString() ??
              "");
      pref.setString("pp", userData['pp']?.toString() ?? "");
      pref.setBool("isLogin", true);

      // Set global constants with fallbacks
      GroceryAppConstant.isLogin = true;
      GroceryAppConstant.email = userData['email']?.toString() ?? "";
      GroceryAppConstant.name = userData['name']?.toString() ?? "";
      GroceryAppConstant.user_id = userData['user_id']?.toString() ??
          userData['userId']?.toString() ??
          "";
      GroceryAppConstant.image = userData['pp']?.toString() ?? "";
      GroceryAppConstant.User_ID = userData['username']?.toString() ??
          userData['mobile']?.toString() ??
          "";

      print("Login successful for user: ${GroceryAppConstant.User_ID}");

      _showLongToast("Login successful");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => GroceryApp()),
        (route) => false,
      );
    } catch (e) {
      print("Error in _handleSuccessfulLogin: $e");
      _showLongToast("Login successful but error saving data: $e");

      // Still navigate to app even if there's an error saving preferences
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => GroceryApp()),
        (route) => false,
      );
    }
  }

  void _showLongToast(String s) {
    Fluttertoast.showToast(
      msg: s,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  Future _getEmployee() async {
    try {
      var map = <String, dynamic>{
        'shop_id': GroceryAppConstant.Shop_id,
        'mobile': nameController.text,
        'password': passwordController.text,
      };

      // 🔍 Print request details
      print("🔸 Login API URL: ${GroceryAppConstant.base_url}api/login.php");
      print("📤 Request Body: $map");

      final response = await http.post(
        Uri.parse(GroceryAppConstant.base_url + 'api/login.php'),
        body: map,
      );

      // 🔍 Print raw response details
      print("📥 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);

        bool isSuccess = false;
        String? successMessage;

        if (jsonBody['success'] == "true") {
          // New format
          isSuccess = true;
          successMessage = jsonBody['message'];
        } else {
          // Old format
          String message = jsonBody['message']?.toString() ?? "";
          if (message.contains("Login is Successful") ||
              message.contains("successful")) {
            isSuccess = true;
            successMessage = message;
          }
        }

        if (isSuccess) {
          setState(() {
            flag = false;
          });

          _showLongToast(successMessage ?? "Login successful");
          _handleSuccessfulLogin(jsonBody);
        } else {
          String errorMessage =
              jsonBody['message']?.toString() ?? "Login failed";
          _showLongToast(errorMessage);
          setState(() {
            flag = false;
          });
        }
      } else {
        _showLongToast("Network error. Please try again.");
        setState(() {
          flag = false;
        });
      }
    } catch (e, stackTrace) {
      // 🔍 Catch any runtime errors
      print("❌ Exception: $e");
      print("📚 StackTrace: $stackTrace");
      _showLongToast("Error: $e");
      setState(() {
        flag = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width!, _pixelRatio!);
    _medium = ResponsiveWidget.isScreenMedium(_width!, _pixelRatio!);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top section with gradient background matching app theme
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      GroceryAppColors.tela,
                      GroceryAppColors.tela1,
                      GroceryAppColors.tela,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -40,
                      right: -50,
                      child: AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value * 0.15,
                            child: Container(
                              width: 180,
                              height: 180,
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
                      bottom: 20,
                      left: -60,
                      child: AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value * 0.12,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // App Logo
                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(12),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 10),
                              // Brand name
                              Text(
                                "HOME SERVICE",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Professional Services at Your Doorstep",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.95),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 32),
                              // Service highlights
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(-2, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: _slideController,
                                      curve: Interval(0.6, 1.0,
                                          curve: Curves.elasticOut),
                                    )),
                                    child: _buildServiceIcon(
                                      Icons.cleaning_services_rounded,
                                      "Cleaning",
                                    ),
                                  ),
                                  SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(0, 2),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: _slideController,
                                      curve: Interval(0.7, 1.0,
                                          curve: Curves.bounceOut),
                                    )),
                                    child: _buildServiceIcon(
                                      Icons.home_repair_service_rounded,
                                      "Repair",
                                    ),
                                  ),
                                  SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(2, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: _slideController,
                                      curve: Interval(0.8, 1.0,
                                          curve: Curves.elasticOut),
                                    )),
                                    child: _buildServiceIcon(
                                      Icons.handyman_rounded,
                                      "Maintenance",
                                    ),
                                  ),
                                ],
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
            // Bottom section with white background and login form
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: GroceryAppColors.tela.withOpacity(0.15),
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 30,
                    bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Form(
                    key: _key,
                    child: isLoadingDesign
                        ? Container(
                            height: 150,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: GroceryAppColors.tela,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Welcome text
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Welcome Back!",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: GroceryAppColors.tela,
                                      height: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "Sign in to continue",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 28),

                              // Mobile number field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 4, bottom: 8),
                                    child: Text(
                                      "Mobile Number",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: GroceryAppColors.tela,
                                      ),
                                    ),
                                  ),
                                  _buildModernTextField(
                                    controller: nameController,
                                    hintText: "Enter your mobile number",
                                    prefixIcon: Icons.phone_android_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),

                              // Show different fields based on login design
                              if (isOtpLogin) ...[
                                // OTP Login Flow
                                if (!isOtpSent) ...[
                                  // Send OTP button
                                  _buildModernButton(
                                    onPressed: _sendLoginOtp,
                                    text: "SEND OTP",
                                    isLoading: flag,
                                  ),
                                  SizedBox(height: 16),
                                  _buildOrDivider(),
                                ] else ...[
                                  // OTP input field
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 4, bottom: 8),
                                        child: Text(
                                          "Enter OTP",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: GroceryAppColors.tela,
                                          ),
                                        ),
                                      ),
                                      _buildModernTextField(
                                        controller: otpController,
                                        hintText: "Enter 6-digit OTP",
                                        prefixIcon: Icons.security_rounded,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  // Resend OTP option
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Didn't receive OTP?",
                                        style: TextStyle(
                                          color: Colors.grey[600],
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
                                          "Resend OTP",
                                          style: TextStyle(
                                            color: GroceryAppColors.tela,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  // Login with OTP button
                                  _buildModernButton(
                                    onPressed: _loginWithOtp,
                                    text: "VERIFY & LOGIN",
                                    isLoading: flag,
                                  ),
                                ],
                              ] else ...[
                                // Password Login Flow
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 4, bottom: 8),
                                      child: Text(
                                        "Password",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: GroceryAppColors.tela,
                                        ),
                                      ),
                                    ),
                                    _buildModernTextField(
                                      controller: passwordController,
                                      hintText: "Enter your password",
                                      prefixIcon: Icons.lock_outline_rounded,
                                      obscureText: _obscurePassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color: GroceryAppColors.tela,
                                          size: 22,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ForgetPass(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                        color: GroceryAppColors.tela,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 28),
                                // Sign in button
                                _buildModernButton(
                                  onPressed: () {
                                    if (!PhoneNumberUtils.isValidMobile(
                                        nameController.text)) {
                                      _showLongToast(
                                          "Please enter a valid 10-digit mobile number");
                                    } else if (passwordController.text.length <
                                        5) {
                                      _showLongToast(
                                          "Password should contain at least 5 letters");
                                    } else {
                                      setState(() {
                                        flag = true;
                                      });
                                      _getEmployee();
                                    }
                                  },
                                  text: "SIGN IN",
                                  isLoading: flag,
                                ),
                                SizedBox(height: 16),
                                _buildOrDivider(),
                              ],

                              SizedBox(height: 20),
                              // Bottom action text and buttons
                              Column(
                                children: [
                                  Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  _buildOutlineButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Form6(
                                            initialMobile:
                                                nameController.text.isNotEmpty
                                                    ? nameController.text
                                                    : null,
                                          ),
                                        ),
                                      );
                                    },
                                    text: "CREATE NEW ACCOUNT",
                                  ),
                                  SizedBox(height: 12),
                                  _buildSecondaryButton(
                                    onPressed: () async {
                                      SharedPreferences pref =
                                          await SharedPreferences.getInstance();
                                      await pref.setBool(
                                          "skipCategorySelection", true);

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => GroceryApp()),
                                        (route) => false,
                                      );
                                    },
                                    text: "Skip for Now",
                                  ),
                                ],
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
    );
  }

  Widget _buildServiceIcon(IconData icon, String label,
      {double iconSize = 16, double fontSize = 9}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "OR",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
      ],
    );
  }

  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required String text,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey[700],
        padding: EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: GroceryAppColors.tela.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GroceryAppColors.tela.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        inputFormatters: keyboardType == TextInputType.number
            ? PhoneNumberUtils.inputFormatters
            : null,
        style: TextStyle(
          fontSize: 15,
          color: Colors.black87,
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
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
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
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            GroceryAppColors.tela,
            GroceryAppColors.tela1,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: GroceryAppColors.tela.withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
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
                  strokeWidth: 2.5,
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

  Widget _buildOutlineButton({
    required VoidCallback onPressed,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: GroceryAppColors.tela,
          width: 2,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: GroceryAppColors.tela.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: GroceryAppColors.tela,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: GroceryAppColors.tela,
          ),
        ),
      ),
    );
  }
}
