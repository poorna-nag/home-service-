import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:EcoShine24/grocery/General/AppConstant.dart';
import 'package:EcoShine24/Auth/signin.dart';
import 'package:EcoShine24/grocery/screen/editprofile.dart';
import 'package:EcoShine24/grocery/screen/trackorder.dart';
import 'package:EcoShine24/grocery/screen/MyReview.dart';
import 'package:EcoShine24/grocery/screen/ShowAddress.dart';
import 'package:EcoShine24/grocery/screen/changePassword.dart';
import 'package:EcoShine24/grocery/Web/WebviewTermandCondition.dart';

class ProfileView extends StatefulWidget {
  final Function? changeView;
  const ProfileView({Key? key, this.changeView}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String name = "";
  String? image;
  String email = "";
  String? mobile;
  String user_id = "";
  bool isloginv = false;
  void gatinfo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    isloginv = pref.getBool("isLogin") ?? false;
    name = pref.getString("name") ?? "";
    email = pref.getString("email") ?? "";
    String image = pref.getString("pp") ?? "";
    String userid = pref.getString("user_id") ?? "";
    mobile = pref.getString("mobile");

    setState(() {
      user_id = userid;
      GroceryAppConstant.name = name;
      GroceryAppConstant.email = email;
      GroceryAppConstant.isLogin = isloginv;
      GroceryAppConstant.User_ID = userid;
      GroceryAppConstant.image = image;

      // print(GroceryAppConstant.image.length);
      // print(GroceryAppConstant.name.length);
      // print("GroceryAppConstant.name");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GroceryAppConstant.isLogin = false;

    gatinfo();
  }

  @override
  Widget build(BuildContext context) {
    print("GroceryAppConstant.check");
    print(GroceryAppConstant.check);
    if (GroceryAppConstant.check) {
      gatinfo();
      setState(() {
        GroceryAppConstant.check = false;
      });
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Gradient Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          GroceryAppColors.tela,
                          GroceryAppColors.tela1,
                          GroceryAppColors.tela.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  // Decorative Circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  // Profile Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile Avatar with Edit Button
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.white.withOpacity(0.9),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(4),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white,
                                    child: ClipOval(
                                      child: SizedBox(
                                        width: 102,
                                        height: 102,
                                        child: GroceryAppConstant.image.isEmpty
                                            ? Image.asset(
                                                'assets/images/logo.png',
                                                fit: BoxFit.cover,
                                              )
                                            : GroceryAppConstant.image.length ==
                                                    1
                                                ? Image.asset(
                                                    'assets/images/logo.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : GroceryAppConstant.image ==
                                                        "https://www.bigwelt.com/manage/uploads/customers/nopp.png"
                                                    ? Image.asset(
                                                        'assets/images/logo.png',
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.network(
                                                        GroceryAppConstant
                                                            .image,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            Image.asset(
                                                          'assets/images/logo.png',
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (GroceryAppConstant.isLogin)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditProfilePage(user_id),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              GroceryAppColors.tela,
                                              GroceryAppColors.tela1,
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: GroceryAppColors.tela
                                                  .withOpacity(0.5),
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // User Name
                          Text(
                            GroceryAppConstant.name == null ||
                                    GroceryAppConstant.name.length <= 1
                                ? "Hello Guest"
                                : GroceryAppConstant.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Email or Sign In Button
                          GroceryAppConstant.isLogin
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.email_outlined,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        GroceryAppConstant.email ?? "",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignInPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.login,
                                          color: GroceryAppColors.tela,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Sign In",
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Area
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Quick Actions Grid
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quick Actions",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.calendar_today_rounded,
                                title: "My Bookings",
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFFF8E53),
                                  ],
                                ),
                                onTap: () {
                                  if (GroceryAppConstant.isLogin) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TrackOrder(),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignInPage(),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.star_rounded,
                                title: "My Reviews",
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFFA726),
                                    Color(0xFFFFB74D),
                                  ],
                                ),
                                onTap: () {
                                  if (GroceryAppConstant.isLogin) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyReview(),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignInPage(),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.location_on_rounded,
                                title: "Addresses",
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF66BB6A),
                                    Color(0xFF81C784),
                                  ],
                                ),
                                onTap: () {
                                  if (GroceryAppConstant.isLogin) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ShowAddress("1"),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignInPage(),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.share_rounded,
                                title: "Share App",
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF42A5F5),
                                    Color(0xFF64B5F6),
                                  ],
                                ),
                                onTap: () {
                                  Platform.isAndroid
                                      ? _shareAndroidApp()
                                      : _shareIosApp();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Account Settings
                  _buildSettingsSection(
                    title: "Account Settings",
                    icon: Icons.person_outline_rounded,
                    children: [
                      _buildSettingsTile(
                        icon: Icons.edit_rounded,
                        title: "Edit Profile",
                        subtitle: "Update your personal information",
                        color: Color(0xFF5C6BC0),
                        onTap: () {
                          if (GroceryAppConstant.isLogin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(user_id),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInPage(),
                              ),
                            );
                          }
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: "Change Password",
                        subtitle: "Update your account password",
                        color: Color(0xFFEF5350),
                        onTap: () {
                          if (GroceryAppConstant.isLogin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePassword(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInPage(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Support & Info
                  _buildSettingsSection(
                    title: "Support & Information",
                    icon: Icons.help_outline_rounded,
                    children: [
                      _buildSettingsTile(
                        icon: Icons.phone_rounded,
                        title: "Contact Us",
                        subtitle: "Get in touch with our team",
                        color: Color(0xFF26A69A),
                        onTap: () {
                          if (GroceryAppConstant.isLogin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewClass(
                                  "Contact Us",
                                  "${GroceryAppConstant.base_url}contact",
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInPage(),
                              ),
                            );
                          }
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: "Privacy Policy",
                        subtitle: "Read our privacy policy",
                        color: Color(0xFF7E57C2),
                        onTap: () {
                          if (GroceryAppConstant.isLogin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewClass(
                                  "Privacy Policy",
                                  "${GroceryAppConstant.base_url}pp",
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInPage(),
                              ),
                            );
                          }
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.description_rounded,
                        title: "Terms & Conditions",
                        subtitle: "View our terms of service",
                        color: Color(0xFFFF7043),
                        onTap: () {
                          if (GroceryAppConstant.isLogin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewClass(
                                  "Terms & Conditions",
                                  "${GroceryAppConstant.base_url}tc",
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInPage(),
                              ),
                            );
                          }
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.info_rounded,
                        title: "About Us",
                        subtitle: "Learn more about us",
                        color: Color(0xFF42A5F5),
                        onTap: () {
                          if (GroceryAppConstant.isLogin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewClass(
                                  "About Us",
                                  "${GroceryAppConstant.base_url}about",
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInPage(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Logout Button
                  GestureDetector(
                    onTap: () {
                      if (GroceryAppConstant.isLogin) {
                        _callLogoutData();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInPage(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: GroceryAppConstant.isLogin
                            ? Color(0xFFFFEBEE)
                            : Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: GroceryAppConstant.isLogin
                              ? Color(0xFFEF5350).withOpacity(0.3)
                              : Color(0xFF66BB6A).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            GroceryAppConstant.isLogin
                                ? Icons.logout_rounded
                                : Icons.login_rounded,
                            color: GroceryAppConstant.isLogin
                                ? Color(0xFFEF5350)
                                : Color(0xFF66BB6A),
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            GroceryAppConstant.isLogin
                                ? "Logout"
                                : "Sign In to Continue",
                            style: TextStyle(
                              color: GroceryAppConstant.isLogin
                                  ? Color(0xFFEF5350)
                                  : Color(0xFF66BB6A),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          GroceryAppColors.tela,
                          GroceryAppColors.tela1,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: GroceryAppColors.tela.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "🇮🇳",
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Made with ❤️ in India",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "🇮🇳",
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for quick action cards
  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for settings sections
  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        GroceryAppColors.tela,
                        GroceryAppColors.tela1,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  // Helper method for settings tiles
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _callLogoutData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    GroceryAppConstant.isLogin = false;
    GroceryAppConstant.email = " ";
    GroceryAppConstant.name = " ";
    GroceryAppConstant.image = " ";

    pref.setString("pp", " ");
    pref.setString("email", " ");
    pref.setString("name", " ");
    pref.setBool("isLogin", false);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SignInPage()));
  }

  _shareAndroidApp() {
    GroceryAppConstant.isLogin
        ? Share.share("Hi, Looking for referral bonuses? Download " +
            GroceryAppConstant.appname +
            " app from this link: https://play.google.com/store/apps/details?id=${GroceryAppConstant.packageName}.\n Don't forget to use my referral code: $mobile")
        : Share.share("Hi, Looking for referral bonuses? Download " +
            GroceryAppConstant.appname +
            " app from this link: https://play.google.com/store/apps/details?id=${GroceryAppConstant.packageName}");
  }

  _shareIosApp() {
    GroceryAppConstant.isLogin
        ? Share.share("Hi, Looking for referral bonuses? Download " +
            GroceryAppConstant.appname +
            " app from this link: ${GroceryAppConstant.iosAppLink}.\n Don't forget to use my referral code: ${mobile}")
        : Share.share("Hi, Looking for referral bonuses? Download " +
            GroceryAppConstant.appname +
            " app from this link:${GroceryAppConstant.iosAppLink}");
  }
}
