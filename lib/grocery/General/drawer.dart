import 'dart:io';

import 'package:EcoShine24/model/ShopDModel.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:EcoShine24/Auth/signin.dart';
import 'package:EcoShine24/grocery/BottomNavigation/profiledraw.dart';
import 'package:EcoShine24/grocery/General/AppConstant.dart';
import 'package:EcoShine24/grocery/General/Home.dart';
import 'package:EcoShine24/grocery/Web/WebviewTermandCondition.dart';
import 'package:EcoShine24/grocery/dbhelper/database_helper.dart';
import 'package:EcoShine24/grocery/screen/ShowAddress.dart';
import 'package:EcoShine24/grocery/screen/myorder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool islogin = false;
  String? name, email, image, cityname, mobile;
  int? wcount;

  ShopDModel? shopDetails;
  SharedPreferences? pref;
  void gatinfo() async {
    pref = await SharedPreferences.getInstance();
    islogin = pref!.getBool("isLogin")!;
    int wcount1 = pref!.getInt("wcount")!;
    name = pref!.getString("name");
    email = pref!.getString("email");
    image = pref!.getString("pp");
    cityname = pref!.getString("city");
    mobile = pref!.getString("mobile");

    // print(islogin);
    setState(() {
      GroceryAppConstant.name = name ?? "";
      GroceryAppConstant.email = email ?? "";
      islogin == null
          ? GroceryAppConstant.isLogin = false
          : GroceryAppConstant.isLogin = islogin;
      GroceryAppConstant.image = image ?? "";
      print(GroceryAppConstant.image);
      GroceryAppConstant.citname = cityname ?? "";

      // print( Constant.image.length);
      wcount = wcount1;
    });
  }

  bool check = false;
  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Select City'),
            content: Container(
              width: double.maxFinite,
              height: 400,
              child: FutureBuilder(
                  future: getPcity(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data == null
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data?.length == null
                                  ? 0
                                  : snapshot.data?.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  width: snapshot.data![index] != 0
                                      ? 130.0
                                      : 230.0,
                                  color: Colors.white,
                                  margin: EdgeInsets.only(right: 10),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        check = true;
                                        pref!.setString('city',
                                            snapshot.data![index].places ?? "");
                                        pref!.setString('cityid',
                                            snapshot.data![index].loc_id ?? "");
                                        GroceryAppConstant.cityid =
                                            snapshot.data![index].loc_id ?? "";
                                        GroceryAppConstant.citname =
                                            snapshot.data![index].places ?? "";

                                        Navigator.pop(context);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  GroceryApp()),
                                        );
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Card(
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: EdgeInsets.all(10),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Text(
                                                snapshot.data![index].places ??
                                                    "",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: GroceryAppColors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Divider(
                                        //
                                        //   color: AppColors.black,
                                        // ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                    }
                    return Center(child: CircularProgressIndicator());
                  }),
            ),
            actions: <Widget>[
              new TextButton(
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: check ? Colors.green : Colors.grey),
                ),
                onPressed: () {
                  check
                      ? Navigator.of(context).pop()
                      : showLongToast("Please Select city");
                },
              )
            ],
          );
        });
  }

  @override
  void initState() {
    gatinfo();
    getShopD().then((value) {
      setState(() {
        shopDetails = value;
      });
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8F9FA),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: <Widget>[
          // Modern Header with Gradient
          Container(
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
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header with Back and Cart
                  Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GroceryApp()),
                            );
                          },
                          icon: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Menu",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 22,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (GroceryAppConstant.isLogin) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TrackOrder()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignInPage()),
                              );
                            }
                          },
                          icon: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              color: GroceryAppColors.tela,
                              size: 22,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                  ),

                  // User Profile Section
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(3),
                          child: CircleAvatar(
                            radius: 33,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: SizedBox(
                                width: 66,
                                height: 66,
                                child: GroceryAppConstant.image.isEmpty ||
                                        GroceryAppConstant.image.length == 1 ||
                                        GroceryAppConstant.image ==
                                            "https://www.bigwelt.com/manage/uploads/customers/nopp.png"
                                    ? Image.asset(
                                        'assets/images/logo.png',
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        GroceryAppConstant.image,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                          'assets/images/logo.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                GroceryAppConstant.name.isEmpty ||
                                        GroceryAppConstant.name.length <= 1
                                    ? "Guest User"
                                    : GroceryAppConstant.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              if (GroceryAppConstant.isLogin)
                                Text(
                                  GroceryAppConstant.email ?? "",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (!GroceryAppConstant.isLogin)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignInPage()),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 6),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Sign In",
                                      style: TextStyle(
                                        color: GroceryAppColors.tela,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Profile Arrow
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileViewdraw()),
                            );
                          },
                          icon: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: <Widget>[
                  // Main Navigation
                  _buildSectionHeader("Main Menu"),
                  _buildModernListTile(
                    icon: Icons.home_rounded,
                    title: 'Home',
                    color: GroceryAppColors.tela,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GroceryApp()),
                      );
                    },
                  ),

                  // My Account Expansion
                  _buildModernExpansionTile(
                    title: 'My Account',
                    icon: Icons.person_rounded,
                    color: GroceryAppColors.tela1,
                    children: [
                      _buildModernSubListTile(
                        icon: Icons.account_circle_rounded,
                        title: "My Profile",
                        color: GroceryAppColors.tela,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileViewdraw()),
                          );
                        },
                      ),
                      _buildModernSubListTile(
                        icon: Icons.shopping_bag_rounded,
                        title: "My Bookings",
                        color: GroceryAppColors.tela1,
                        onTap: () {
                          if (GroceryAppConstant.isLogin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TrackOrder()),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignInPage()),
                            );
                          }
                        },
                      ),
                      _buildModernSubListTile(
                        icon: Icons.location_on_rounded,
                        title: "My Addresses",
                        color: GroceryAppColors.tela,
                        onTap: () {
                          if (GroceryAppConstant.isLogin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ShowAddress("1")),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignInPage()),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 8),
                  _buildSectionHeader("Support & Info"),

                  _buildModernListTile(
                    icon: Icons.phone_rounded,
                    title: 'Contact Us',
                    color: GroceryAppColors.tela,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewClass("Contact Us",
                                  "${GroceryAppConstant.base_url}contact")));
                    },
                  ),
                  _buildModernListTile(
                    icon: Icons.privacy_tip_rounded,
                    title: 'Privacy Policy',
                    color: GroceryAppColors.tela1,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewClass(
                                  "Privacy Policy",
                                  "${GroceryAppConstant.base_url}pp")));
                    },
                  ),
                  _buildModernListTile(
                    icon: Icons.info_rounded,
                    title: 'About Us',
                    color: GroceryAppColors.tela1,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewClass("About Us",
                                  "${GroceryAppConstant.base_url}about")));
                    },
                  ),
                  _buildModernListTile(
                    icon: Icons.description_rounded,
                    title: 'Terms & Conditions',
                    color: GroceryAppColors.tela,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewClass(
                                  "Terms & Conditions",
                                  "${GroceryAppConstant.base_url}tc")));
                    },
                  ),
                  _buildModernListTile(
                    icon: Icons.share_rounded,
                    title: 'Share App',
                    color: GroceryAppColors.tela1,
                    onTap: () {
                      _shairApp();
                    },
                  ),

                  if (!GroceryAppConstant.isLogin)
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignInPage()),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
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
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.login_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Sign In to Continue",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Logo Section
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    height: 100,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/icon/Home services 1.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Social Media
                  if (shopDetails != null) socialMedia(context),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28, 12, 16, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [GroceryAppColors.tela, GroceryAppColors.tela1],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  _shairApp() {
    Share.share("Hi, Looking for best deals online? Download " +
        GroceryAppConstant.appname +
        " app form click on this link  https://play.google.com/store/apps/details?id=${GroceryAppConstant.packageName}");
  }

  Widget rateUs() {
    return InkWell(
        onTap: () {
          String os = Platform.operatingSystem; //in your code
          if (os == 'android') {
            final InAppReview inAppReview = InAppReview.instance;
            inAppReview.openStoreListing(
              appStoreId: "com.chickenista",
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 12.0),
          child: Row(
            children: <Widget>[
              Text(
                "Rate Us",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ));
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
            " app from this link: https://play.google.com/store/apps/details?id=${GroceryAppConstant.packageName}.\n Don't forget to use my referral code: ${mobile}")
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

  Widget socialMedia(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GroceryAppColors.tela.withOpacity(0.08),
            GroceryAppColors.tela1.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GroceryAppColors.tela.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [GroceryAppColors.tela, GroceryAppColors.tela1],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 10),
              Text(
                "Connect With Us",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  shopDetails!.mobileNo != null || shopDetails!.mobileNo != ''
                      ? naviagteToFacebook('tel:+91${shopDetails!.mobileNo}')
                      : showLongToast('No Mobile Number');
                },
                child: _buildSocialMediaIcon(
                  'assets/images/phone.png',
                  GroceryAppColors.tela,
                ),
              ),
              InkWell(
                onTap: () {
                  shopDetails!.i != null || shopDetails!.i != ''
                      ? naviagteToInstagram(shopDetails!.i)
                      : showLongToast('No Link Available');
                },
                child: _buildSocialMediaIcon(
                  'assets/images/insta.png',
                  GroceryAppColors.tela1,
                ),
              ),
              InkWell(
                onTap: () {
                  shopDetails!.w != null || shopDetails!.w != ''
                      ? naviagteTotwitter(shopDetails!.w!.startsWith('+')
                          ? 'https://wa.me/${shopDetails!.w}/?text=Hy '
                          : shopDetails!.w!.startsWith('91')
                              ? 'https://wa.me/+${shopDetails!.w}/?text=Hy '
                              : 'https://wa.me/+91${shopDetails!.w}/?text=Hy ')
                      : showLongToast('No number Available');
                },
                child: _buildSocialMediaIcon(
                  'assets/images/whatsapp.png',
                  GroceryAppColors.tela,
                ),
              ),
              InkWell(
                onTap: () {
                  shopDetails!.f != null || shopDetails!.f != ''
                      ? naviagteToYoutube(shopDetails!.f)
                      : showLongToast('No Link Available');
                },
                child: _buildSocialMediaIcon(
                  'assets/images/facebook.png',
                  GroceryAppColors.tela1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaIcon(String imagePath, Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(14),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget socialMediaIcons(String image) {
    return Container(
      height: 30,
      width: 30,
      decoration:
          BoxDecoration(image: DecorationImage(image: AssetImage(image))),
    );
  }

  Future<void> naviagteToFacebook(link) async {
    final url = Uri.parse(link);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> naviagteToInstagram(link) async {
    final url = Uri.parse(link);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> naviagteTotwitter(link) async {
    final url = Uri.parse(link);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> naviagteToteligram(link) async {
    final url = Uri.parse(link);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> naviagteToYoutube(link) async {
    final url = Uri.parse(link);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // Helper method to build modern list tiles
  Widget _buildModernListTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.05)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: color,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build modern expansion tiles
  Widget _buildModernExpansionTile({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: color.withOpacity(0.1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: EdgeInsets.only(bottom: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            iconColor: color,
            collapsedIconColor: color,
            children: children,
          ),
        ),
      ),
    );
  }

  // Helper method to build modern sub list tiles
  Widget _buildModernSubListTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(left: 60, right: 16, bottom: 6, top: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.05),
            color.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color.withOpacity(0.6),
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
