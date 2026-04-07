import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:EcoShine24/constent/app_constent.dart';
import 'package:EcoShine24/grocery/General/AppConstant.dart';
import 'package:EcoShine24/grocery/dbhelper/CarrtDbhelper.dart';
import 'package:EcoShine24/grocery/screen/ShowAddress.dart';
import 'package:EcoShine24/grocery/General/Home.dart';

import 'package:shared_preferences/shared_preferences.dart';

class WishList extends StatefulWidget {
  final bool? check;
  final VoidCallback? onStartShopping;

  const WishList({Key? key, this.check, this.onStartShopping})
      : super(key: key);
  @override
  WishlistState createState() => WishlistState();
}

class WishlistState extends State<WishList> with TickerProviderStateMixin {
  final DbProductManager dbmanager = new DbProductManager();
  static List<ProductsCart>? prodctlist;
  static List<ProductsCart>? prodctlist1;
  double totalamount = 0;

  int _count = 1;
  bool islogin = false;
  bool isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  void gatinfo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    islogin = pref.getBool("isLogin") ?? false;
    setState(() {
      GroceryAppConstant.isLogin = islogin;
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    gatinfo();
    _loadCartData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _loadCartData() async {
    setState(() {
      isLoading = true;
      totalamount = 0;
    });

    dbmanager.getProductList().then((usersFromServe) {
      if (this.mounted) {
        setState(() {
          prodctlist1 = usersFromServe;
          isLoading = false;

          for (var i = 0; i < prodctlist1!.length; i++) {
            totalamount =
                totalamount + double.parse(prodctlist1![i].pprice ?? "0");
          }
          GroceryAppConstant.totalAmount = totalamount;
          GroceryAppConstant.itemcount = prodctlist1!.length;
        });

        // Start animations after data loads
        _fadeController.forward();
        _slideController.forward();
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          isLoading = false;
          prodctlist1 = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GroceryAppColors.bg, // Blue background
      appBar: _buildModernAppBar(),
      body: isLoading
          ? _buildLoadingState()
          : prodctlist1 == null || prodctlist1!.isEmpty
              ? _buildEmptyState()
              : _buildCartContent(),
      floatingActionButton:
          (prodctlist1?.isNotEmpty ?? false) ? _buildFloatingCheckout() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
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
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => GroceryApp()),
            (route) => false,
          );
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Cart',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!isLoading && prodctlist1 != null)
            Text(
              '${prodctlist1!.length} ${prodctlist1!.length == 1 ? 'item' : 'items'}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
      actions: [
        if (prodctlist1?.isNotEmpty ?? false)
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _showClearCartDialog,
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                GroceryAppColors.tela), // Blue theme
            strokeWidth: 3,
          ),
          SizedBox(height: 24),
          Text(
            'Loading your cart...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GroceryAppColors.tela.withOpacity(0.1), // Blue theme
                      GroceryAppColors.tela1.withOpacity(0.05), // Blue theme
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: GroceryAppColors.tela.withOpacity(0.2), // Blue theme
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 60,
                  color: GroceryAppColors.tela, // Blue theme
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Add some services to get started',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GroceryAppColors.tela,
                      GroceryAppColors.tela1
                    ], // Blue theme
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color:
                          GroceryAppColors.tela.withOpacity(0.3), // Blue theme
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (widget.onStartShopping != null) {
                      widget.onStartShopping!();
                      return;
                    }

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => GroceryApp()),
                      (route) => false,
                    );
                  },
                  icon: Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  label: Text(
                    'Start Shopping',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 8, bottom: 100),
                itemCount: prodctlist1!.length,
                itemBuilder: (context, index) =>
                    _buildModernCartItem(prodctlist1![index], index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCartItem(ProductsCart item, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Dismissible(
        key: Key('${item.id}_${index}'),
        direction: DismissDirection.endToStart,
        background: _buildSwipeBackground(),
        confirmDismiss: (direction) async {
          return await _showDeleteConfirmation(item.pname ?? 'this item');
        },
        onDismissed: (direction) => _removeItem(item, index),
        child: Card(
          elevation: 3,
          shadowColor: GroceryAppColors.tela.withOpacity(0.1), // Blue theme
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: GroceryAppColors.white,
              border: Border.all(
                color: GroceryAppColors.tela.withOpacity(0.1), // Blue theme
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _buildProductImage(item),
                SizedBox(width: 12),
                Expanded(child: _buildProductDetails(item)),
                // Quantity stepper removed as per client requirement
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductsCart item) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            GroceryAppColors.tela.withOpacity(0.05), // Blue theme
            GroceryAppColors.tela1.withOpacity(0.03), // Blue theme
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: GroceryAppColors.tela.withOpacity(0.1), // Blue theme
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: '${GroceryAppConstant.Product_Imageurl}${item.pimage}',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: GroceryAppColors.tela.withOpacity(0.05), // Blue theme
            child: Icon(Icons.image,
                color: GroceryAppColors.tela.withOpacity(0.4)), // Blue theme
          ),
          errorWidget: (context, url, error) => Container(
            color: GroceryAppColors.tela.withOpacity(0.05), // Blue theme
            child: Icon(Icons.broken_image,
                color: GroceryAppColors.tela.withOpacity(0.4)), // Blue theme
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails(ProductsCart item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.pname ?? 'Unknown Service',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: GroceryAppColors.black,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        if (item.pcolor?.isNotEmpty ?? false)
          _buildAttributeChip('Color: ${item.pcolor}', Icons.palette_outlined),
        if (item.psize?.isNotEmpty ?? false)
          _buildAttributeChip('Size: ${item.psize}', Icons.straighten_outlined),
        SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GroceryAppColors.tela.withOpacity(0.1), // Blue theme
                    GroceryAppColors.tela1.withOpacity(0.05), // Blue theme
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: GroceryAppColors.tela.withOpacity(0.2), // Blue theme
                  width: 1,
                ),
              ),
              child: Text(
                '₹${double.parse(item.pprice ?? "0").toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: GroceryAppColors.tela, // Blue theme
                ),
              ),
            ),
          ],
        ),
        // Quantity stepper moved to right side
      ],
    );
  }

  Widget _buildAttributeChip(String text, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon,
              size: 14,
              color: GroceryAppColors.tela.withOpacity(0.7)), // Blue theme
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Quantity stepper removed as per client requirement

  Widget _buildSwipeBackground() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[400]!, Colors.red[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCheckout() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(30),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                GroceryAppColors.tela,
                GroceryAppColors.tela1
              ], // Blue gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: GroceryAppColors.tela.withOpacity(0.4),
                blurRadius: 15,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: _proceedToCheckout,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Book Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '₹${GroceryAppConstant.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for cart operations
  Future<bool?> _showDeleteConfirmation(String itemName) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.delete_outline, color: Colors.red, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Remove Item',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove $itemName from your cart?',
            style: TextStyle(color: Colors.grey[600]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[400]!, Colors.red[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Remove',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.clear_all, color: Colors.red, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Clear Cart',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove all items from your cart?',
            style: TextStyle(color: Colors.grey[600]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[400]!, Colors.red[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _clearAllItems();
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearAllItems() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    for (var item in prodctlist1!) {
      dbmanager.deleteProducts(item.id!);
    }

    setState(() {
      prodctlist1!.clear();
      totalamount = 0;
      GroceryAppConstant.totalAmount = 0;
      GroceryAppConstant.itemcount = 0;
      GroceryAppConstant.groceryAppCartItemCount = 0;
      AppConstent.cc = 0;
      pref.setInt("cc", 0);
    });

    _showToast('Cart cleared successfully');
  }

  void _removeItem(ProductsCart item, int index) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    dbmanager.deleteProducts(item.id!);

    setState(() {
      prodctlist1!.removeAt(index);
      double itemPrice = double.parse(item.pprice ?? "0");
      totalamount -= itemPrice;
      GroceryAppConstant.totalAmount -= itemPrice;
      GroceryAppConstant.itemcount--;
      GroceryAppConstant.groceryAppCartItemCount =
          GroceryAppConstant.groceryAppCartItemCount > 0
              ? GroceryAppConstant.groceryAppCartItemCount - 1
              : 0;
      AppConstent.cc = AppConstent.cc > 0 ? AppConstent.cc - 1 : 0;
      pref.setInt("cc", AppConstent.cc);
    });

    _showToast('${item.pname ?? "Item"} removed from cart');
    groceryCartItemCount(GroceryAppConstant.groceryAppCartItemCount);
  }

  void _proceedToCheckout() {
    if (GroceryAppConstant.itemcount > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ShowAddress("0")),
      );
    } else {
      _showToast('Please add some products first!');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  Future<void> groceryCartItemCount(int count) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("itemCount", count);
  }

  // Quantity handlers removed as per client requirement
}
