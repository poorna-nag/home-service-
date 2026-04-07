import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart';
import 'package:EcoShine24/grocery/Auth/signin.dart';
import 'package:EcoShine24/grocery/BottomNavigation/wishlist.dart';
import 'package:EcoShine24/grocery/General/AppConstant.dart';
import 'package:EcoShine24/grocery/dbhelper/CarrtDbhelper.dart';
import 'package:EcoShine24/grocery/dbhelper/database_helper.dart';
import 'package:EcoShine24/grocery/dbhelper/wishlistdart.dart';
import 'package:EcoShine24/grocery/model/Gallerymodel.dart';
import 'package:EcoShine24/grocery/model/GroupProducts.dart';
import 'package:EcoShine24/grocery/model/Varient.dart';
import 'package:EcoShine24/grocery/model/productmodel.dart';
import 'package:EcoShine24/grocery/screen/Zoomimage.dart';
import 'package:EcoShine24/grocery/screen/detailpage.dart';
import 'package:EcoShine24/grocery/screen/secondtabview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetails1 extends StatefulWidget {
  final String id;
  const ProductDetails1(this.id) : super();

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails1> {
  List<PVariant> pvarlist = [];
  String name = "";
  String textval = "Select varient";
  _displayDialog(BuildContext context, int position) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Select Variant'),
            content: Container(
              width: double.maxFinite,
              height: pvarlist.length * 50.0,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: pvarlist.length == null ? 0 : pvarlist.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      width: pvarlist[index] != 0 ? 130.0 : 230.0,
                      color: Colors.white,
                      margin: EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            total = int.parse(pvarlist[index].price ?? "");
                            String mrp_price = calDiscount(
                                pvarlist[index].price ?? "",
                                pvarlist[index].discount ?? "");
                            totalmrp = double.parse(mrp_price);
                            textval = pvarlist[index].variant ?? "";
                            name = pvarlist[index].variant ?? "";
                            // imgList1[position].

                            Navigator.pop(context);
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                pvarlist[index].variant ?? "",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: GroceryAppColors.black,
                                ),
                              ),
                            ),
                            Divider(
                              color: GroceryAppColors.black,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body?.text).documentElement!.text;

    return parsedString;
  }

  int _current = 0;
  bool flag = true;
  bool wishflag = true;
  int? wishid;
  String? url;
  List<Products> products1 = [];
  List<String> catid = [];

  final List<String> imgList1 = [
    'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  ];
  List<GroupProducts> group = [];

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  int _count = 1;
  String? _dropDownValue, groupname = "";
  String? _dropDownValue1;
  int? total;
  int actualprice = 200;
  double? mrp, totalmrp;
  double? sgst1, cgst1, dicountValue, admindiscountprice;
  List<String>? size;
  List<String>? color;

  List<Gallery> galiryImage1 = [];
  List<Products> productdetails = [];
  ProductsCart? products;
  Products? prod;
  final DbProductManager dbmanager = new DbProductManager();

//  DatabaseHelper helper = DatabaseHelper();
//  Note note ;

  void gatinfoCount() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    int? Count = pref.getInt("itemCount");
    bool? ligin = pref.getBool("isLogin");

    setState(() {
      GroceryAppConstant.isLogin = ligin!;

      if (Count == null) {
        GroceryAppConstant.groceryAppCartItemCount = 0;
      } else {
        GroceryAppConstant.groceryAppCartItemCount = Count;
      }
//      print(Constant.carditemCount.toString()+"itemCount");
    });
  }

  String? id;
  @override
  void initState() {
    super.initState();

    // Check if widget.id is valid before making API calls
    if (widget.id.isEmpty) {
      // Handle empty ID case
      Navigator.pop(context);
      return;
    }

    gatinfoCount();
    productdetail(widget.id).then((usersFromServe) {
      if (mounted) {
        setState(() {
          if (usersFromServe != null && usersFromServe.isNotEmpty) {
            productdetails = usersFromServe;
            setState(() {
              url = productdetails[0].img;
              id = productdetails[0].productIs;
              actualprice = int.parse(productdetails[0].buyPrice ?? "0");
              total = actualprice;

              String mrp_price = calDiscount(productdetails[0].buyPrice ?? "0",
                  productdetails[0].discount ?? "0");
              totalmrp = double.parse(mrp_price);

              String adiscount = calDiscount(productdetails[0].buyPrice ?? "0",
                  productdetails[0].msrp ?? "0");
              admindiscountprice =
                  (double.parse(productdetails[0].buyPrice ?? "0") -
                      double.parse(adiscount));
              dicountValue =
                  double.parse(productdetails[0].buyPrice ?? "0") - totalmrp!;
              String gst_sgst =
                  calGst(totalmrp.toString(), productdetails[0].sgst ?? "0");
              String gst_cgst =
                  calGst(totalmrp.toString(), productdetails[0].cgst ?? "0");

              // Add null checks for color and size
              if (productdetails[0].productColor != null &&
                  productdetails[0].productColor!.isNotEmpty) {
                color = productdetails[0].productColor!.split(',');
              } else {
                color = ['Default'];
              }

              if (productdetails[0].productScale != null &&
                  productdetails[0].productScale!.isNotEmpty) {
                size = productdetails[0].productScale!.split(',');
              } else {
                size = ['Default'];
              }

              sgst1 = double.parse(gst_sgst);
              cgst1 = double.parse(gst_cgst);

              // Add null check for productLine
              if (productdetails[0].productLine != null &&
                  productdetails[0].productLine!.isNotEmpty) {
                print(productdetails[0].productLine! + "product id");
                catid = productdetails[0].productLine!.split(',');
                catby_productData(catid.length > 0 ? catid[0] : "0", "0")
                    .then((usersFromServe) {
                  if (mounted) {
                    setState(() {
                      products1 = usersFromServe ?? [];
                    });
                  }
                });
              }

              GroupPro(productdetails[0].productIs ?? "")
                  .then((usersFromServe) {
                if (mounted) {
                  setState(() {
                    group = usersFromServe ?? [];
                    groupname = (group.isNotEmpty && group[0].name != null)
                        ? group[0].name!
                        : "";
                  });
                }
              });

              dbmanager1.getProductList3().then((usersFromServe) {
                if (mounted) {
                  setState(() {
                    prodctlist1 = usersFromServe;
                    if (prodctlist1 != null) {
                      for (var i = 0; i < prodctlist1!.length; i++) {
                        if (prodctlist1![i].pid == id) {
                          wishflag = false;
                          wishid = prodctlist1![i].id;
                          break;
                        }
                      }
                    }
                  });
                }
              });
            });
          } else {
            // Handle case when no product details are found
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Product not found"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pop(context);
          }
        });
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading product details"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    });

    DatabaseHelper.getImage(widget.id).then((usersFromServe) {
      if (mounted) {
        setState(() {
          galiryImage1 = usersFromServe ?? [];
          imgList1.clear();
          for (var i = 0; i < galiryImage1.length; i++) {
            imgList1.add(galiryImage1[i].img ?? "");
          }
        });
      }
    });

    getPvarient(widget.id).then((usersFromServe) {
      if (mounted) {
        setState(() {
          pvarlist = usersFromServe ?? [];
        });
      }
    });
  }

  bool showdis = false;

  static List<WishlistsCart>? prodctlist1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GroceryAppColors.tela,
            GroceryAppColors.tela1,
            GroceryAppColors.tela,
          ],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
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
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: GroceryAppColors.tela,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            title: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                "Product Details",
                style: TextStyle(
                  color: GroceryAppColors.tela,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            centerTitle: true,
            actions: <Widget>[
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WishList()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Stack(
                      children: <Widget>[
                        Icon(
                          Icons.add_shopping_cart,
                          color: GroceryAppColors.tela,
                          size: 24,
                        ),
                        if (GroceryAppConstant.groceryAppCartItemCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    GroceryAppColors.tela,
                                    GroceryAppColors.tela1
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        GroceryAppColors.tela.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              constraints: BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                '${GroceryAppConstant.groceryAppCartItemCount}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
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
          body: Container(
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                        margin: EdgeInsets.only(
                            top: 80), // Add top margin for app bar
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Modern Image Carousel Section
                            Container(
                              margin: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: imgList1 != null && imgList1.length > 0
                                  ? Container(
                                      height: 280,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CarouselSlider.builder(
                                          itemCount: imgList1.length,
                                          options: CarouselOptions(
                                            height: 280,
                                            aspectRatio: 1.2,
                                            enlargeCenterPage: true,
                                            autoPlay: true,
                                            autoPlayInterval:
                                                Duration(seconds: 3),
                                            autoPlayAnimationDuration:
                                                Duration(milliseconds: 800),
                                            autoPlayCurve: Curves.fastOutSlowIn,
                                            pauseAutoPlayOnTouch: true,
                                            viewportFraction: 0.9,
                                          ),
                                          itemBuilder: (ctx, index, realIdx) {
                                            return Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 12),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ZoomImage(
                                                                imgList1)),
                                                  );
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        GroceryAppColors.tela
                                                            .withOpacity(0.1),
                                                        Colors.transparent,
                                                      ],
                                                    ),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    child: CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      imageUrl: GroceryAppConstant
                                                              .Product_Imageurl2 +
                                                          imgList1[index],
                                                      placeholder:
                                                          (context, url) =>
                                                              Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              GroceryAppColors
                                                                  .tela
                                                                  .withOpacity(
                                                                      0.1),
                                                              GroceryAppColors
                                                                  .tela1
                                                                  .withOpacity(
                                                                      0.05),
                                                            ],
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                    Color>(
                                                              GroceryAppColors
                                                                  .tela,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              GroceryAppColors
                                                                  .tela
                                                                  .withOpacity(
                                                                      0.1),
                                                              GroceryAppColors
                                                                  .tela1
                                                                  .withOpacity(
                                                                      0.05),
                                                            ],
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.broken_image,
                                                            color: Color(
                                                                0xFF1B5E20),
                                                            size: 40,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 280,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF1B5E20).withOpacity(0.1),
                                            Color(0xFF2E7D32).withOpacity(0.05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image_not_supported,
                                              color: GroceryAppColors.tela,
                                              size: 48,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              "No images available",
                                              style: TextStyle(
                                                color: Color(0xFF1B5E20),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),

                            // Modern Image Indicators
                            if (imgList1 != null && imgList1.length > 1)
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      imgList1.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    return AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      width: _current == index ? 24 : 8,
                                      height: 8,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        gradient: _current == index
                                            ? LinearGradient(
                                                colors: [
                                                  GroceryAppColors.tela,
                                                  GroceryAppColors.tela1
                                                ],
                                              )
                                            : null,
                                        color: _current == index
                                            ? null
                                            : Colors.grey.withOpacity(0.4),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                            // Modern Product Info Card
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with icon
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF1B5E20),
                                              Color(0xFF2E7D32)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Icon(
                                          Icons.cleaning_services,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Product Information",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: GroceryAppColors.tela,
                                              ),
                                            ),
                                            Text(
                                              "Professional cleaning service",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 20),

                                  // Product Name
                                  Text(
                                    name.isNotEmpty ? name : "Product Name",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                      height: 1.3,
                                    ),
                                  ),

                                  SizedBox(height: 20),

                                  // Modern Price Section
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          GroceryAppColors.tela
                                              .withOpacity(0.05),
                                          GroceryAppColors.tela1
                                              .withOpacity(0.02),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: GroceryAppColors.tela
                                            .withOpacity(0.1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.currency_rupee,
                                          color: GroceryAppColors.tela,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Service Price",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  // Current Price
                                                  Text(
                                                    '₹${(totalmrp! * _count).toStringAsFixed(GroceryAppConstant.val)}',
                                                    style: TextStyle(
                                                      fontSize: 28,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          GroceryAppColors.tela,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),

                                                  // Original Price (if different)
                                                  if (total != null &&
                                                      total !=
                                                          (totalmrp! * _count)
                                                              .round())
                                                    Text(
                                                      '₹$total',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Discount Badge
                                        if (total != null &&
                                            total !=
                                                (totalmrp! * _count).round())
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  GroceryAppColors.tela,
                                                  GroceryAppColors.tela1
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.green
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.local_offer,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${total! > 0 ? (((total! - (totalmrp! * _count)) / total!) * 100).abs().toStringAsFixed(0) : "0"}% OFF',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Modern Variant Selection & Quantity Section
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF1B5E20),
                                              Color(0xFF2E7D32)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.tune,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Text(
                                        "Customize Order",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1B5E20),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 20),

                                  // Quantity Section
                                  Text(
                                    "Select Quantity",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),

                                  SizedBox(height: 12),

                                  Row(
                                    children: [
                                      // Decrease Button
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF1B5E20)
                                                  .withOpacity(0.1),
                                              Color(0xFF2E7D32)
                                                  .withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            color: Color(0xFF1B5E20)
                                                .withOpacity(0.2),
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            onTap: _count > 1
                                                ? () {
                                                    setState(() {
                                                      _count--;
                                                    });
                                                  }
                                                : null,
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              child: Icon(
                                                Icons.remove,
                                                color: _count > 1
                                                    ? Color(0xFF1B5E20)
                                                    : Colors.grey[400],
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Quantity Display
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 16),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF1B5E20),
                                                Color(0xFF2E7D32)
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFF1B5E20)
                                                    .withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            '$_count',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Increase Button
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF1B5E20)
                                                  .withOpacity(0.1),
                                              Color(0xFF2E7D32)
                                                  .withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            color: Color(0xFF1B5E20)
                                                .withOpacity(0.2),
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            onTap: () {
                                              setState(() {
                                                _count++;
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              child: Icon(
                                                Icons.add,
                                                color: Color(0xFF1B5E20),
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 16),

                                  // Total Price
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF1B5E20).withOpacity(0.05),
                                          Color(0xFF2E7D32).withOpacity(0.02),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            Color(0xFF1B5E20).withOpacity(0.1),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Total Amount:",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          '₹${(totalmrp! * _count).toStringAsFixed(GroceryAppConstant.val)}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1B5E20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Modern Action Buttons Section
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  // Add to Wishlist Button
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      height: 56,
                                      margin: EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF1B5E20).withOpacity(0.1),
                                            Color(0xFF2E7D32).withOpacity(0.05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Color(0xFF1B5E20)
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          onTap: () {
                                            // Add to wishlist functionality
                                            _addToproducts1(context);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(16),
                                            child: Icon(
                                              Icons.favorite_border,
                                              color: Color(0xFF1B5E20),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Add to Cart Button
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF1B5E20),
                                            Color(0xFF2E7D32),
                                            Color(0xFF388E3C)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF1B5E20)
                                                .withOpacity(0.4),
                                            blurRadius: 12,
                                            offset: Offset(0, 6),
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          onTap: () {
                                            // Add to cart functionality
                                            _addToproducts(context);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 16),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Icon(
                                                    Icons.add_shopping_cart,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  "Add to Cart",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FutureBuilder(
                                future: productdetail(widget.id),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return ListView.builder(
                                      itemCount: snapshot.data!.length == null
                                          ? 0
                                          : snapshot.data!.length,
                                      shrinkWrap: true,
                                      primary: false,
                                      scrollDirection: Axis.vertical,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        Products item = snapshot.data![index];
                                        return Container(
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: map<Widget>(imgList1,
                                                    (index, url) {
                                                  return Container(
                                                    width: 25.0,
                                                    height: 0.0,
                                                    child: Container(),
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 4.0,
                                                            vertical: 7.0),
//                                decoration: BoxDecoration(
//                                  shape: BoxShape.rectangle,
//                                  color: _current == index ? Colors.orange : Colors.grey,
//                                ),
                                                  );
                                                }),
                                              ),

//                          productName1(),

                                              Container(
//                        height: 90,

                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),

                                                margin: EdgeInsets.only(
                                                    left: 10, right: 20),
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      // item.productColor.length<2?Container():  Container(
                                                      //   width: 60,
                                                      //   height: 25,
                                                      //   decoration:BoxDecoration(
                                                      //
                                                      //     borderRadius: BorderRadius.circular(15),
                                                      //     color: Colors.red,
                                                      //   ),
                                                      //   child: Text(""),
                                                      // ) ,

                                                      item.productColor!
                                                                  .length <
                                                              2
                                                          ? Container()
                                                          : Container(
                                                              width: 120,
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                child:
                                                                    DropdownButton(
                                                                  elevation: 0,
                                                                  hint: _dropDownValue ==
                                                                          null
                                                                      ? Text(
                                                                          'Select color')
                                                                      : Text(
                                                                          _dropDownValue ??
                                                                              "",
                                                                          style:
                                                                              TextStyle(color: Colors.blue),
                                                                        ),
                                                                  isExpanded:
                                                                      true,
                                                                  iconSize:
                                                                      30.0,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue),
                                                                  items: color!
                                                                      .map(
                                                                    (val) {
                                                                      return DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            val,
                                                                        child: Text(
                                                                            val),
                                                                      );
                                                                    },
                                                                  ).toList(),
                                                                  onChanged:
                                                                      (val) {
                                                                    setState(
                                                                      () {
                                                                        _dropDownValue =
                                                                            val;
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                      SizedBox(
                                                        width: 20,
                                                      ),
                                                      Expanded(
                                                        child:
                                                            item.productScale!
                                                                        .length <
                                                                    2
                                                                ? Container()
                                                                : Container(
                                                                    width: 120,
                                                                    child:
                                                                        DropdownButton(
                                                                      hint: _dropDownValue1 ==
                                                                              null
                                                                          ? Text(
                                                                              'Select Size')
                                                                          : Text(
                                                                              _dropDownValue1 ?? "",
                                                                              style: TextStyle(color: Colors.blue),
                                                                            ),
                                                                      isExpanded:
                                                                          true,
                                                                      iconSize:
                                                                          30.0,
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.blue),
                                                                      items: size!
                                                                          .map(
                                                                        (val) {
                                                                          return DropdownMenuItem<
                                                                              String>(
                                                                            value:
                                                                                val,
                                                                            child:
                                                                                Text(val),
                                                                          );
                                                                        },
                                                                      ).toList(),
                                                                      onChanged:
                                                                          (val) {
                                                                        setState(
                                                                          () {
                                                                            _dropDownValue1 =
                                                                                val;
                                                                          },
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                      )
                                                    ]),
                                              ),

                                              // SizedBox(height: 15,),

                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: 0.0, right: 30),
                                                child: Row(children: <Widget>[
                                                  SizedBox(
                                                    width: 0.0,
                                                    height: 10.0,
                                                  ),
                                                  Column(
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 15),
                                                              height: 33,
                                                              width: 40,
                                                              child: Material(
                                                                color:
                                                                    GroceryAppColors
                                                                        .tela,
                                                                elevation: 0.0,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            2),
                                                                  ),
                                                                ),
                                                                clipBehavior: Clip
                                                                    .antiAlias,
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      if (_count !=
                                                                          1) {
                                                                        setState(
                                                                            () {
                                                                          _count--;
//                                                        totalmrp=mrp * _count;
                                                                        });
                                                                      }
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          EdgeInsets
                                                                              .only(
                                                                        top:
                                                                            10.0,
                                                                      ),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .maximize,
                                                                        size:
                                                                            30,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    )),
                                                              )),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 0.0,
                                                                    left: 10.0,
                                                                    right: 8.0),
                                                            child: Center(
                                                              child: Text(
                                                                  '$_count',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          19,
                                                                      fontFamily:
                                                                          'Roboto',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            ),
                                                          ),
                                                          Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          3.0),
                                                              height: 33,
                                                              width: 40,
                                                              child: Material(
                                                                color:
                                                                    GroceryAppColors
                                                                        .tela,
                                                                elevation: 0.0,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            2),
                                                                  ),
                                                                ),
                                                                clipBehavior: Clip
                                                                    .antiAlias,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    if (_count <=
                                                                        int.parse(item.quantityInStock ??
                                                                            "")) {
                                                                      print(item
                                                                          .quantityInStock);
                                                                      setState(
                                                                          () {
                                                                        print(
                                                                            _count);
                                                                        _count++;
//                                                     totalmrp=mrp * _count;
                                                                      });
                                                                    } else {
                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                          content: Text(
                                                                              " Products  is not avaliable "),
                                                                          duration:
                                                                              Duration(seconds: 1)));
                                                                    }
                                                                  },
                                                                  child: Icon(
                                                                    Icons.add,
                                                                    size: 30,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              )),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  Column(
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          SizedBox(width: 10),
                                                          Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          3.0),
                                                              height: 35,
                                                              child: Material(
                                                                color:
                                                                    GroceryAppColors
                                                                        .tela,
                                                                elevation: 0.0,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                ),
                                                                clipBehavior: Clip
                                                                    .antiAlias,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    if (GroceryAppConstant
                                                                        .isLogin) {
//
                                                                      if (item.productColor!.length >
                                                                              0 &&
                                                                          item.productScale!.length >
                                                                              0) {
                                                                        if (_dropDownValue !=
                                                                                null &&
                                                                            _dropDownValue1 !=
                                                                                null) {
                                                                          if (int.parse(item.quantityInStock ?? "") >
                                                                              0) {
                                                                            _addToproducts(context);
                                                                            GroceryAppConstant.groceryAppCartItemCount++;
                                                                            groceryCartItemCount(GroceryAppConstant.groceryAppCartItemCount);
                                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                                content: Text(" Services  is added to cart "),
                                                                                duration: Duration(seconds: 1)));
                                                                            setState(() {
                                                                              GroceryAppConstant.itemcount++;

//                                                  print( Constant.totalAmount);
                                                                            });
                                                                          } else {
                                                                            showLongToast("Product is out of stock");
                                                                          }
                                                                        } else {
                                                                          showLongToast(
                                                                              "Please select coor and size");
                                                                        }
                                                                      } else if (item
                                                                              .productColor!
                                                                              .length >
                                                                          2) {
                                                                        if (_dropDownValue !=
                                                                            null) {
                                                                          if (int.parse(item.quantityInStock ?? "") >
                                                                              0) {
                                                                            _addToproducts(context);
                                                                            GroceryAppConstant.groceryAppCartItemCount++;
                                                                            groceryCartItemCount(GroceryAppConstant.groceryAppCartItemCount);
                                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                                content: Text(" Services  is added to cart "),
                                                                                duration: Duration(seconds: 1)));
                                                                            setState(() {
                                                                              GroceryAppConstant.itemcount++;

//                                                  print( Constant.totalAmount);
                                                                            });
                                                                          } else {
                                                                            showLongToast("Product is out of stock");
                                                                          }
                                                                        } else {
                                                                          showLongToast(
                                                                              "Please select color");
                                                                        }
                                                                      } else if (item
                                                                              .productScale!
                                                                              .length >
                                                                          2) {
                                                                        if (_dropDownValue1 !=
                                                                            null) {
                                                                          if (int.parse(item.quantityInStock ?? "") >
                                                                              0) {
                                                                            _addToproducts(context);
                                                                            GroceryAppConstant.groceryAppCartItemCount++;
                                                                            groceryCartItemCount(GroceryAppConstant.groceryAppCartItemCount);
                                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                                content: Text(" Services  is added to cart "),
                                                                                duration: Duration(seconds: 1)));
                                                                            setState(() {
                                                                              GroceryAppConstant.itemcount++;

//                                                  print( Constant.totalAmount);
                                                                            });
                                                                          } else {
                                                                            showLongToast("Product is out of stock");
                                                                          }
                                                                        } else {
                                                                          showLongToast(
                                                                              "Please select size");
                                                                        }
                                                                      } else {
                                                                        if (int.parse(item.quantityInStock ??
                                                                                "") >
                                                                            0) {
                                                                          _addToproducts(
                                                                              context);
                                                                          GroceryAppConstant
                                                                              .groceryAppCartItemCount++;
                                                                          groceryCartItemCount(
                                                                              GroceryAppConstant.groceryAppCartItemCount);
                                                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                              content: Text(" Services  is added to cart "),
                                                                              duration: Duration(seconds: 1)));
                                                                          setState(
                                                                              () {
                                                                            GroceryAppConstant.itemcount++;

//                                                  print( Constant.totalAmount);
                                                                          });
                                                                        } else {
                                                                          showLongToast(
                                                                              "Product is out of stock");
                                                                        }
                                                                      }
                                                                    } else {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                SignInPage()),
                                                                      );
                                                                    }
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                          padding: EdgeInsets.only(
                                                                              left: 8,
                                                                              top: 5,
                                                                              bottom: 5,
                                                                              right: 8),
                                                                          child: Center(
                                                                            child:
                                                                                Text(
                                                                              "Book",
                                                                              style: TextStyle(color: GroceryAppColors.white),
                                                                            ),
                                                                          )),
                                                                ),
                                                              )),
//                                                     wishflag
//                                                         ? InkWell(
//                                                             onTap: () {
//                                                               if (GroceryAppConstant
//                                                                   .isLogin) {
//                                                                 _addToproducts1(
//                                                                     context);

//                                                                 showLongToast(
//                                                                     " Products  is added to wishlist ");

//                                                                 setState(() {
//                                                                   wishflag =
//                                                                       false;
//                                                                   GroceryAppConstant
//                                                                       .wishlist++;
//                                                                   _countList(
//                                                                       GroceryAppConstant
//                                                                           .wishlist);

// //                                                  print( Constant.totalAmount);
//                                                                 });
//                                                               } else {
//                                                                 Navigator.push(
//                                                                   context,
//                                                                   MaterialPageRoute(
//                                                                       builder:
//                                                                           (context) =>
//                                                                               SignInPage()),
//                                                                 );
//                                                               }
//                                                             },
//                                                             child: Container(
//                                                               margin: EdgeInsets
//                                                                   .only(
//                                                                       left:
//                                                                           3.0),
//                                                               height: 33,
//                                                               width: 45,
//                                                               child: Icon(
//                                                                   Icons
//                                                                       .favorite_border,
//                                                                   size: 30,
//                                                                   color:
//                                                                       GroceryAppColors
//                                                                           .pink),
//                                                             ),
//                                                           )
//                                                         : InkWell(
//                                                             onTap: () {
//                                                               setState(() {
//                                                                 dbmanager1
//                                                                     .deleteProducts(
//                                                                         wishid!);
//                                                                 wishflag = true;
//                                                               });
//                                                             },
//                                                             child: Container(
//                                                               margin: EdgeInsets
//                                                                   .only(
//                                                                       left:
//                                                                           3.0),
//                                                               height: 33,
//                                                               width: 45,
//                                                               child: Icon(
//                                                                   Icons
//                                                                       .favorite,
//                                                                   size: 30,
//                                                                   color:
//                                                                       GroceryAppColors
//                                                                           .pink),
//                                                             ),
//                                                           ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ]),
                                              ),

                                              pvarlist.length > 0
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 16.0,
                                                                  top: 18.0),
                                                          child: new Text(
                                                            ' Variant:',
                                                            style:
                                                                new TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 16.0,
                                                                    top: 8.0),
                                                            child: InkWell(
                                                              onTap: () {
                                                                _displayDialog(
                                                                    context,
                                                                    index);
                                                                // _showSelectionDialog(context);
                                                              },
                                                              child: Container(
                                                                // width: MediaQuery.of(context).size.width/1.5,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  left: 10.0,
                                                                  top: 0.0,
                                                                  right: 10.0,
                                                                ),
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  top: 5.0,
                                                                ),

                                                                child: Center(
                                                                    child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10),
                                                                      child:
                                                                          Text(
                                                                        textval.length >
                                                                                20
                                                                            ? textval.substring(0, 20) +
                                                                                ".."
                                                                            : textval,

                                                                        overflow:
                                                                            TextOverflow.fade,
                                                                        // maxLines: 2,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              GroceryAppColors.black,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                0),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .expand_more,
                                                                          color:
                                                                              Colors.black,
                                                                          size:
                                                                              30,
                                                                        ))
                                                                  ],
                                                                )),

                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .black)),
                                                              ),
                                                            )),

                                                        /*Container(
                                 color: AppColors.black,
                                   margin:EdgeInsets.only(left: 10,top: 10,right: 10) ,
                                   height: 45,
                                   child: Padding(
                                     padding: EdgeInsets.only(left: 0,top: 0,right: 0),
                                     child: TextField(
                                         minLines: 1,
                                         maxLines: 3,
                                         decoration: InputDecoration(
                                           prefixIcon: Icon(Icons.expand_more),
                                             hintText: "Select varient",
                                             border: OutlineInputBorder()
                                         )),))*/
                                                      ],
                                                    )
                                                  : Row(),

                                              SizedBox(
                                                height: 20,
                                              ),

                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16.0,
                                                            top: 8.0),
                                                    child: new Text(
                                                      'Product Details:',
                                                      style: new TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      if (showdis) {
                                                        setState(() {
                                                          showdis = false;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          showdis = true;
                                                        });
                                                      }
                                                    },
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 16.0,
                                                                top: 8.0),
                                                        child: Icon(
                                                            showdis
                                                                ? Icons
                                                                    .keyboard_arrow_up
                                                                : Icons
                                                                    .keyboard_arrow_down,

//                                        Icons.keyboard_arrow_down,
                                                            size: 30,
                                                            color:
                                                                GroceryAppColors
                                                                    .black)),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              showdis
                                                  ? Column(
                                                      children: <Widget>[
                                                        // discription("Warranty: ",item.warrantys),

                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          16.0,
                                                                      top: 8.0),
                                                              child: Text(
                                                                "Return: ",
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      15.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          16.0,
                                                                      top: 8.0),
                                                              child: Text(
                                                                item.returns ==
                                                                        "0"
                                                                    ? "No"
                                                                    : item.returns ??
                                                                        "" +
                                                                            "day",
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      14.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
//                             discription("Return: ",widget.plist.returns),
//                                                 discription("Brand: ",item.productVendor),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          16.0,
                                                                      top: 8.0),
                                                              child: Text(
                                                                "Cancel: ",
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      15.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          16.0,
                                                                      top: 8.0),
                                                              child: Text(
                                                                item.cancels ==
                                                                        "0"
                                                                    ? "No"
                                                                    : item.cancels! +
                                                                        "day",
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      14.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        discription1(
                                                            _parseHtmlString(
                                                                item.productDescription ??
                                                                    "")),
                                                      ],
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                }),
                            group != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      group != null
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10.0, top: 8.0),
                                              child: Text(
                                                groupname ?? "",
                                                style: new TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : Row(),
                                      Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        height: 78.0,
                                        child: group != null
                                            ? ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: group.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return group[index]
                                                              .img!
                                                              .length >
                                                          2
                                                      ? Container(
                                                          width: 70.0,
                                                          child: Card(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                            ),
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            child: InkWell(
                                                              onTap: () {
//                                              setState(() {
//
//                                                url=imgList1[index];
//                                                showLongToast("Product is selected ");
//                                              });
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          ProductDetails1(group[index].productIs ??
                                                                              "")),
                                                                );
//
                                                              },
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <Widget>[
                                                                  SizedBox(
                                                                      height:
                                                                          70,
                                                                      child: Image.network(
                                                                          GroceryAppConstant.Product_Imageurl1 +
                                                                              group[index].img.toString(),
                                                                          fit: BoxFit.cover)
                                                                      /*CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    imageUrl:Constant.Product_Imageurl1+group[index].img,
//                                                  =="no-cover.png"? getImage(topProducts[index].productIs):topProducts[index].image,
                                                    placeholder: (context, url) =>
                                                        Center(
                                                            child:
                                                            CircularProgressIndicator()),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                    new Icon(Icons.error),

                                                  ),*/
                                                                      ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Row();
                                                })
                                            : CircularProgressIndicator(),
                                      ),
                                    ],
                                  )
                                : Row(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 8.0, left: 11.0, right: 8.0),
                                  child: Text(
                                    'RELATED PRODUCTS',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8.0, top: 8.0, left: 8.0),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: GroceryAppColors.tela,
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      child: Text('View All',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onPressed: () {
                                        print(catid.length);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Screen2(
                                                  catid.length > 0
                                                      ? catid[0]
                                                      : "0",
                                                  "RELATED PRODUCTS")),
                                        );
                                      }),
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              height: 235.0,
                              child: products1 != null
                                  ? ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: products1.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          width: 150.0,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProductDetails(
                                                              products1[
                                                                  index])),
                                                );
//
                                              },
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 165,
                                                    width: double.infinity,
                                                    child: CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      imageUrl: GroceryAppConstant
                                                              .Product_Imageurl +
                                                          products1[index]
                                                              .img
                                                              .toString(),
//                                                  =="no-cover.png"? getImage(topProducts[index].productIs):topProducts[index].image,
                                                      placeholder: (context,
                                                              url) =>
                                                          Center(
                                                              child:
                                                                  CircularProgressIndicator()),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          new Icon(Icons.error),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 5,
                                                          right: 0,
                                                          top: 5),
                                                      padding: EdgeInsets.only(
                                                          left: 3, right: 5),
                                                      color: GroceryAppColors
                                                          .white,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            products1[index]
                                                                    .productName ??
                                                                "",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  GroceryAppColors
                                                                      .black,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '(\u{20B9} ${products1[index].buyPrice})',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 2,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                    fontSize:
                                                                        12,
                                                                    color: GroceryAppColors
                                                                        .black,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                child: Text(
                                                                    '\u{20B9} ${calDiscount(products1[index].buyPrice ?? "", products1[index].discount ?? "")}',
                                                                    style: TextStyle(
                                                                        color: GroceryAppColors
                                                                            .green,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        fontSize:
                                                                            12)),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      })
                                  : CircularProgressIndicator(),
                            ),
                          ],
                        ),
                      ),
                      childCount: 1,
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

  productName1() {
    actualprice = int.parse(productdetails[0].buyPrice ?? "");
    total = actualprice;

    String mrp_price = calDiscount(
        productdetails[0].buyPrice ?? "", productdetails[0].discount ?? "");
    totalmrp = double.parse(mrp_price);

    Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 5, left: 10),
      child: Text(
          productdetails[0].productName == null
              ? productdetails[0].productName!.length.toString()
              : "sanjar",
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          )),
    );
  }

  priceold() {
    Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 1),
      child: Text('\u{20B9} $total',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: GroceryAppColors.mrp,
              decoration: TextDecoration.lineThrough)),
    );
  }

  priceNew() {
    Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 1),
      child: Text(
          totalmrp != null
              ? '\u{20B9} ${(totalmrp! * _count).toStringAsFixed(2)}'
              : '1000',
//                              total.toString()==null?'\u{20B9} $total':actualprice.toString(),
          style: TextStyle(
            color: GroceryAppColors.sellp,
            fontWeight: FontWeight.w700,
          )),
    );
  }

  productDetails() {
    Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
      child: Text(
        productdetails[0].productDescription ?? "",
        style: new TextStyle(
          color: Colors.black,
          fontSize: 14.0,
        ),
      ),
    );
  }

//  discountValue;
//  String adminper;
//  String adminpricevalue;
//  String costPrice;

  void _addToproducts(BuildContext context) {
    if (products == null) {
      ProductsCart st = new ProductsCart(
          pid: productdetails[0].productIs,
          pname: productdetails[0].productName,
          pimage: url,
          pprice: (totalmrp! * _count).toString(),
          pQuantity: _count,
          pcolor: _dropDownValue,
          psize: _dropDownValue1,
          pdiscription: productdetails[0].productDescription,
          sgst: sgst1.toString(),
          cgst: cgst1.toString(),
          discount: productdetails[0].discount,
          discountValue: dicountValue.toString(),
          adminper: productdetails[0].msrp,
          adminpricevalue: admindiscountprice.toString(),
          costPrice: total.toString(),
          shipping: productdetails[0].shipping,
          totalQuantity: productdetails[0].quantityInStock,
          varient: textval,
          mv: int.parse(productdetails[0].mv ?? ""));
      dbmanager
          .insertStudent(st)
          .then((id) => {print('Student Added to Db ${id}')});
    }
  }

  WishlistsCart? nproducts;
  final DbProductManager1 dbmanager1 = new DbProductManager1();

  void _addToproducts1(BuildContext context) {
    if (nproducts == null) {
      WishlistsCart st1 = new WishlistsCart(
          pid: productdetails[0].productIs,
          pname: productdetails[0].productName,
          pimage: url,
          pprice: totalmrp.toString(),
          pQuantity: _count,
          pcolor: _dropDownValue,
          psize: _dropDownValue1,
          pdiscription: productdetails[0].productDescription,
          sgst: sgst1.toString(),
          cgst: cgst1.toString(),
          discount: productdetails[0].discount,
          discountValue: dicountValue.toString(),
          adminper: productdetails[0].msrp,
          adminpricevalue: admindiscountprice.toString(),
          costPrice: productdetails[0].buyPrice);
      dbmanager1.insertStudent(st1).then((id) => {
            setState(() {
              wishid = id;

              print('Student Added to Db ${wishid}');
              print(GroceryAppConstant.totalAmount);
            })
          });
    }
  }

  String calDiscount(String byprice, String discount2) {
    String returnStr;
    double discount = 0.0;
    returnStr = discount.toString();
    double byprice1 = double.parse(byprice);
    double discount1 = double.parse(discount2);

    discount = (byprice1 - (byprice1 * discount1) / 100.0);

    returnStr = discount.toStringAsFixed(2);
    print(returnStr);
    return returnStr;
  }

  String calGst(String byprice, String sgst) {
    String returnStr;
    double discount = 0.0;
    returnStr = discount.toString();
    double byprice1 = double.parse(byprice);
    double discount1 = double.parse(sgst);

    discount = ((byprice1 * discount1) / (100.0 + discount1));

    returnStr = discount.toStringAsFixed(2);
    print(returnStr);
    return returnStr;
  }

  void showLongToast(String s) {
    Fluttertoast.showToast(
      msg: s,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  Widget discription1(String Discription) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                '${_parseHtmlString(Discription ?? "")}',
                overflow: TextOverflow.fade,
                style: new TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget discription(String name, String Discription) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
            child: Text(
              name,
              overflow: TextOverflow.fade,
              style: new TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                Discription != null ? Discription : "",
                overflow: TextOverflow.fade,
                style: new TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _countList(int val) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("wcount", val);
  }
}
