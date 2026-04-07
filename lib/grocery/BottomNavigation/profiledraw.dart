import 'package:flutter/material.dart';
import 'package:EcoShine24/Auth/signin.dart';
import 'package:EcoShine24/General/AppConstant.dart';
import 'package:EcoShine24/dbhelper/CarrtDbhelper.dart' as food;
import 'package:EcoShine24/grocery/General/AppConstant.dart';
import 'package:EcoShine24/grocery/dbhelper/CarrtDbhelper.dart' as grocery;
import 'package:EcoShine24/grocery/screen/MyReview.dart';
import 'package:EcoShine24/grocery/screen/ShowAddress.dart';
import 'package:EcoShine24/grocery/screen/changePassword.dart';
import 'package:EcoShine24/grocery/screen/editprofile.dart';
import 'package:EcoShine24/grocery/screen/myorder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileViewdraw extends StatefulWidget {
  final Function? changeView;

  const ProfileViewdraw({Key? key, this.changeView}) : super(key: key);

  @override
  _ProfileViewdrawState createState() => _ProfileViewdrawState();
}

class _ProfileViewdrawState extends State<ProfileViewdraw> {
  String name = "";
  String? image;
  String email = "";
  String user_id = "";
  bool isloginv = false;
  final food.DbProductManager dbmanager1 = new food.DbProductManager();
  final grocery.DbProductManager dbmanager2 = new grocery.DbProductManager();
  //final service.DbProductManager dbmanager3 = new service.DbProductManager();

  void gatinfo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    isloginv = pref.getBool("isLogin")!;
    name = pref.getString("name")!;
    email = pref.getString("email")!;
    String image = pref.getString("pp")!;
    String userid = pref.getString("user_id")!;

    setState(() {
      user_id = userid;
      GroceryAppConstant.name = name;
      GroceryAppConstant.email = email;
      GroceryAppConstant.isLogin = isloginv;
      GroceryAppConstant.User_ID = userid;
      GroceryAppConstant.image = image;

      // print(Constant.image.length);
      // print(Constant.name.length);
      // print("Constant.name");
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
    print("Constant.check");
    print(GroceryAppConstant.check);
    if (GroceryAppConstant.check) {
      gatinfo();
      setState(() {
        GroceryAppConstant.check = false;
      });
    }

    return Scaffold(
      backgroundColor: GroceryAppColors.bg,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: GroceryAppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "My Profile",
          style: TextStyle(
            color: GroceryAppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
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
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Profile Header Section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    GroceryAppColors.tela1,
                    GroceryAppColors.lightBlueBg,
                  ],
                ),
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  children: <Widget>[
                    // Profile Avatar
                    Container(
                      width: 120.0,
                      height: 120.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: new SizedBox(
                            width: 112.0,
                            height: 112.0,
                            child: GroceryAppConstant.image == null
                                ? Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.cover,
                                  )
                                : GroceryAppConstant.image.length == 1
                                    ? Image.asset('assets/images/logo.png',
                                        fit: BoxFit.cover)
                                    : GroceryAppConstant.image ==
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
                    const SizedBox(height: 20),
                    // User Name
                    Text(
                      GroceryAppConstant.name == null
                          ? "Hello Guest"
                          : GroceryAppConstant.name.length == 1
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
                    // Email or Login Button
                    GroceryAppConstant.isLogin
                        ? Text(
                            GroceryAppConstant.email == null
                                ? " "
                                : GroceryAppConstant.email,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignInPage()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                "Tap to Sign In",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),

            // Menu Items Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // My Bookings
                  _buildModernListTile(
                    icon: Icons.shopping_bag_outlined,
                    title: "My Bookings",
                    color: GroceryAppColors.tela,
                    onTap: () {
                      if (GroceryAppConstant.isLogin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TrackOrder()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Service Address
                  _buildModernListTile(
                    icon: Icons.location_on_outlined,
                    title: "Service Address",
                    color: GroceryAppColors.tela1,
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
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // My Review
                  _buildModernListTile(
                    icon: Icons.star_outline_rounded,
                    title: "My Review",
                    color: GroceryAppColors.lightBlueBg,
                    onTap: () {
                      if (GroceryAppConstant.isLogin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyReview()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Update Password
                  _buildModernListTile(
                    icon: Icons.lock_outline_rounded,
                    title: "Update Password",
                    color: GroceryAppColors.tela,
                    onTap: () {
                      if (FoodAppConstant.isLogin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangePassword()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Update Profile
                  _buildModernListTile(
                    icon: Icons.edit_outlined,
                    title: "Update Profile",
                    color: GroceryAppColors.tela1,
                    onTap: () {
                      if (GroceryAppConstant.isLogin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfilePage(user_id)),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Logout/Login
                  _buildModernListTile(
                    icon: GroceryAppConstant.isLogin
                        ? Icons.logout_outlined
                        : Icons.login_outlined,
                    title: GroceryAppConstant.isLogin ? "Logout" : "Login",
                    color: GroceryAppConstant.isLogin
                        ? Color(0xFFD32F2F) // Keep red for logout
                        : GroceryAppColors.lightBlueBg,
                    onTap: () {
                      if (GroceryAppConstant.isLogin) {
                        _callLogoutData();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build modern list tiles
  Widget _buildModernListTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: GroceryAppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: GroceryAppColors.tela.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: GroceryAppColors.tela.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        GroceryAppColors.tela.withOpacity(0.15),
                        GroceryAppColors.tela1.withOpacity(0.05)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: GroceryAppColors.tela.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: GroceryAppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: GroceryAppColors.tela.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: GroceryAppColors.tela,
                    size: 16,
                  ),
                ),
              ],
            ),
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
    dbmanager1.deleteallProducts();
    dbmanager2.deleteallProducts();

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SignInPage()));
  }
}
