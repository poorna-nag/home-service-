import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:EcoShine24/grocery/General/AppConstant.dart';
import 'package:EcoShine24/grocery/dbhelper/database_helper.dart';
import 'package:EcoShine24/grocery/model/MyReviewModel.dart';
import 'package:EcoShine24/grocery/screen/detailpage1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readmore/readmore.dart';

class MyReview extends StatefulWidget {
  @override
  _TrackOrderState createState() => _TrackOrderState();
}

class _TrackOrderState extends State<MyReview> {
  Future<void> getUserInfo() async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    String? userid = pre.getString("user_id");
    this.setState(() {
      GroceryAppConstant.user_id = userid ?? "";
    });
  }

  int line = 2;
  String textval = "Show more";
  bool flag = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
    print(GroceryAppConstant.user_id);
    print("Constant.user_id");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GroceryAppColors.tela1,
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: EdgeInsets.all(20),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: GroceryAppColors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: GroceryAppColors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: GroceryAppColors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: GroceryAppColors.boxColor1,
                            size: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "My Reviews",
                            style: TextStyle(
                              color: GroceryAppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Container(width: 36), // For symmetry
                    ],
                  ),
                ),
              ),
              // Body Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: FutureBuilder(
                      future: myReview(GroceryAppConstant.user_id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return _buildEmptyState();
                          }
                          print(snapshot.data!.length);
                          return ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (BuildContext context, int index) {
                                Review item = snapshot.data![index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 16),
                                  child: Card(
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            GroceryAppColors.tela1,
                                            GroceryAppColors.tela
                                                .withOpacity(0.02),
                                          ],
                                        ),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductDetails1(
                                                        item.product ?? "")),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Product name and header
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: GroceryAppColors
                                                          .tela
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Icon(
                                                      Icons.rate_review,
                                                      color:
                                                          GroceryAppColors.tela,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      item.productName != null
                                                          ? item.productName ??
                                                              ""
                                                          : "Product",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: GroceryAppColors
                                                            .tela,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 16),

                                              // Rating section
                                              Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: GroceryAppColors.tela
                                                      .withOpacity(0.05),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Rating: ",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: GroceryAppColors
                                                            .tela1,
                                                      ),
                                                    ),
                                                    RatingBar.builder(
                                                      initialRating:
                                                          double.parse(
                                                              item.stars ??
                                                                  "0"),
                                                      minRating: 1,
                                                      direction:
                                                          Axis.horizontal,
                                                      allowHalfRating: false,
                                                      itemCount: 5,
                                                      itemSize: 20,
                                                      itemPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 2.0),
                                                      itemBuilder:
                                                          (context, _) => Icon(
                                                        Icons.star,
                                                        color: Colors.amber,
                                                      ),
                                                      onRatingUpdate:
                                                          (rating) {},
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      "(${item.stars ?? "0"}/5)",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: GroceryAppColors
                                                            .tela,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 16),

                                              // Review text
                                              ReadMoreText(
                                                item.review ??
                                                    "No review provided",
                                                trimLines: 3,
                                                colorClickableText:
                                                    GroceryAppColors.tela,
                                                trimMode: TrimMode.Line,
                                                trimCollapsedText: ' Show more',
                                                trimExpandedText: ' Show less',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: GroceryAppColors.tela1,
                                                  height: 1.4,
                                                ),
                                                moreStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: GroceryAppColors.tela,
                                                ),
                                                lessStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: GroceryAppColors.tela,
                                                ),
                                              ),
                                              SizedBox(height: 16),

                                              // Date and footer
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: GroceryAppColors.tela1
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.calendar_today,
                                                          size: 16,
                                                          color:
                                                              GroceryAppColors
                                                                  .tela1,
                                                        ),
                                                        SizedBox(width: 6),
                                                        Text(
                                                          item.dates ?? "",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                GroceryAppColors
                                                                    .tela1,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: GroceryAppColors
                                                            .tela,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      child: Text(
                                                        "View Product",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              GroceryAppColors
                                                                  .tela1,
                                                          fontWeight:
                                                              FontWeight.w600,
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
                                    ),
                                  ),
                                );
                              });
                        } else {
                          return Center(
                            child: Container(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                color: GroceryAppColors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          );
                        }
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ...existing code...
  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.only(top: 50),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: GroceryAppColors.tela1.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: GroceryAppColors.tela1.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.rate_review_outlined,
                size: 60,
                color: GroceryAppColors.tela1.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 24),
            Text(
              "No Reviews Yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: GroceryAppColors.tela1,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "You haven't written any reviews yet.\nStart shopping and share your experience!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: GroceryAppColors.tela1.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GroceryAppColors.tela,
                    GroceryAppColors.tela1.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  "Start Shopping",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: GroceryAppColors.tela,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
