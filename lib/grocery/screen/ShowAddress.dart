import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:EcoShine24/grocery/General/AppConstant.dart';
import 'package:EcoShine24/grocery/dbhelper/database_helper.dart';
import 'package:EcoShine24/grocery/model/AddressModel.dart';
import 'package:http/http.dart' as http;
import 'package:EcoShine24/grocery/model/RegisterModel.dart';
import 'package:EcoShine24/grocery/screen/checkout.dart';
import 'package:EcoShine24/grocery/General/Home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AddAddress.dart';
import 'UpdateAddress.dart';

class ShowAddress extends StatefulWidget {
  final String valu;
  const ShowAddress(this.valu) : super();
  @override
  _ShowAddressState createState() => _ShowAddressState();
}

class _ShowAddressState extends State<ShowAddress> {
  List<UserAddress> add = [];
  bool isloading = false;
  String? selectedAddressId;
//  void checkAddress(){
//    if(widget.valu=="0"&& add.length>0){
//      Navigator.push(context,
//        MaterialPageRoute(builder: (context) => AddAddress()),);
//
//    }
//  }
  bool _status = false;
  @override
  void initState() {
    super.initState();
    isloading = true;
    _loadSelectedAddressId();
    getAddress().then((usersFromServe) {
      setState(() {
        add = usersFromServe!;
        isloading = false;
      });
    });
  }

  Future<void> _loadSelectedAddressId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      selectedAddressId = pref.getString("selected_address_id");
    });
  }

  Future<void> _selectAddress(UserAddress selected) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final String addressText = [
      selected.address1,
      selected.address2,
      selected.city,
      selected.state,
      selected.pincode,
    ].where((part) => part != null && part!.trim().isNotEmpty).join(", ");

    await pref.setString("selected_address_id", selected.addId ?? "");
    await pref.setString("address", selected.address1 ?? "");
    await pref.setString("add", addressText);

    if (selected.lat != null && selected.lat!.isNotEmpty) {
      await pref.setString("lat", selected.lat!);
      GroceryAppConstant.latitude = double.tryParse(selected.lat!) ?? 0.0;
    }
    if (selected.lng != null && selected.lng!.isNotEmpty) {
      await pref.setString("lng", selected.lng!);
      GroceryAppConstant.longitude = double.tryParse(selected.lng!) ?? 0.0;
    }

    if (!mounted) return;
    setState(() {
      selectedAddressId = selected.addId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 8,
        backgroundColor: GroceryAppColors.boxColor1,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [GroceryAppColors.boxColor1, GroceryAppColors.boxColor2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.add,
              color: GroceryAppColors.white,
              size: 28,
            ),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAddress(widget.valu)),
          );
        },
      ),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [GroceryAppColors.boxColor1, GroceryAppColors.boxColor2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            color: GroceryAppColors.white,
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              // Navigate back to home screen to avoid black screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => GroceryApp()),
                (route) => false,
              );
            }),
        title: Text(
          "My Address",
          maxLines: 2,
          style: TextStyle(
            color: GroceryAppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          // _status?screen():
          Container(
        decoration: BoxDecoration(
          color: GroceryAppColors.bg,
        ),
        child: isloading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(GroceryAppColors.boxColor1),
                ),
              )
            : add.isEmpty
                ? Center(
                    child: Text(
                      'No Address Found!....',
                      style: TextStyle(
                        color: GroceryAppColors.boxColor1,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : add.length > 0
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: add.length <= 0 ? 0 : add.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              if (widget.valu == "0") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UpDateAddress(
                                          add[index], widget.valu)),
                                );
                              } else {
                                _selectAddress(add[index]).then((_) {
                                  if (!mounted) return;
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GroceryApp()),
                                    (route) => false,
                                  );
                                });
                              }
                            },
                            child: Container(
                              margin:
                                  EdgeInsets.only(top: 10, left: 10, right: 10),
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                elevation: 8.0,
                                shadowColor:
                                    GroceryAppColors.boxColor1.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [
                                        GroceryAppColors.white,
                                        GroceryAppColors.bg
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: GroceryAppColors.boxColor1
                                          .withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      if (selectedAddressId == add[index].addId)
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: GroceryAppColors.boxColor1
                                                .withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle_rounded,
                                                color:
                                                    GroceryAppColors.boxColor1,
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "Selected for Home Screen",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: GroceryAppColors
                                                      .boxColor1,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      add[index].label != null
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, top: 6, right: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  add[index].fullName != null
                                                      ? Text(
                                                          add[index].fullName !=
                                                                  null
                                                              ? add[index]
                                                                  .fullName!
                                                              : "",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  GroceryAppColors
                                                                      .boxColor1,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        )
                                                      : SizedBox(),
                                                  Text(
                                                    add[index].label != null
                                                        ? add[index].label ?? ""
                                                        : "",
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: GroceryAppColors
                                                            .boxColor2,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : SizedBox(),

                                      add[index].address1!.length > 1
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10, top: 5),
                                                    child: Text(
                                                      add[index].address1 !=
                                                              null
                                                          ? add[index]
                                                                  .address1 ??
                                                              ""
                                                          : "",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: GroceryAppColors
                                                            .boxColor1
                                                            .withOpacity(0.8),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(
                                              height: 0,
                                            ),

                                      add[index].mobile!.length > 1
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10, top: 5),
                                                  child: Text(
                                                    add[index].mobile != null
                                                        ? add[index]
                                                                .mobile
                                                                .toString() +
                                                            ',' +
                                                            add[index]
                                                                .email
                                                                .toString()
                                                        : "",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(),

//                             add[index].city != null
//                                 ? Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: Padding(
//                                           padding:
//                                               EdgeInsets.only(left: 10, top: 5),
//                                           child: Text(
//                                             add[index].city != null
//                                                 ? add[index].city.toString() +
//                                                     ", " +
//                                                     add[index]
//                                                         .state
//                                                         .toString() +
//                                                     ", " +
//                                                     add[index]
//                                                         .pincode
//                                                         .toString()
//                                                 : "",
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                                 : Row(),

// //                  setContainer("Name",add[index].fullName),
//                             setContainer("Mobile No", add[index].mobile ?? ""),
//                             setContainer("Email Id", add[index].email ?? ""),

                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 10, top: 2, right: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Padding(
                                                    padding:
                                                        EdgeInsets.all(2.0),
                                                    child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          elevation: 0,
                                                          backgroundColor:
                                                              GroceryAppColors
                                                                  .white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    UpDateAddress(
                                                                        add[
                                                                            index],
                                                                        widget
                                                                            .valu)),
                                                          );
                                                        },
//              splashColor: AppColors.tela,

                                                        child: Icon(Icons.edit)

                                                        //  Text(
                                                        //   "Update",
                                                        //   style: TextStyle(
                                                        //     fontSize: 12,
                                                        //     color: Colors.white,
                                                        //   ),
                                                        // ),
                                                        )),
                                                Padding(
                                                  padding: EdgeInsets.all(2.0),
                                                  child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        elevation: 0,
                                                        backgroundColor:
                                                            Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0)),
                                                      ),
                                                      onPressed: () {
                                                        print("Delete");
                                                        showDilogueReviw(
                                                            context, index);
                                                      },
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      )
                                                      //  Text(
                                                      //   "Delete",
                                                      //   style: TextStyle(
                                                      //     fontSize: 12,
                                                      //     color: Colors.white,
                                                      //   ),
                                                      // ),
                                                      ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                                padding: EdgeInsets.all(2.0),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor:
                                                        GroceryAppColors.tela,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    final selected = add[index];
                                                    _selectAddress(selected)
                                                        .then((_) {
                                                      if (!mounted) return;
                                                      if (widget.valu == "0") {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                CheckOutPage(
                                                                    selected),
                                                          ),
                                                        );
                                                      } else {
                                                        Navigator
                                                            .pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                GroceryApp(),
                                                          ),
                                                          (route) => false,
                                                        );
                                                      }
                                                    });
                                                  },
                                                  child: Text(
                                                    widget.valu == "0"
                                                        ? 'Continue >>'
                                                        : 'Select Address',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),

                                                  //  Text(
                                                  //   "Next",
                                                  //   style: TextStyle(
                                                  //     fontSize: 12,
                                                  //     color: Colors.white,
                                                  //   ),
                                                  // ),
                                                )),
                                          ],
                                        ),
                                      )
//                  getAction(context,index),
//                  setContainer("City",add[index].city),
//                  setContainer("State",add[index].state),
//                  setContainer("Pin",add[index].pincode),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        })
                    : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget getAction(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 2, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(2.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GroceryAppColors.boxColor1,
                  foregroundColor: GroceryAppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  elevation: 4,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UpDateAddress(add[index], widget.valu),
                    ),
                  );
                },
//              splashColor: AppColors.tela,

                child: Text(
                  "Update",
                  style: TextStyle(
                    fontSize: 14,
                    color: GroceryAppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
          Padding(
            padding: EdgeInsets.all(2.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: GroceryAppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)),
                elevation: 4,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
//                _deleteAdderss(add[index].addId);
//                add.removeAt(index);
                showDilogueReviw(context, index);
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  fontSize: 14,
                  color: GroceryAppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget setContainer(String title, String value) {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(2.0),
            child: Text(
              title + ':',
              style: TextStyle(
                  fontSize: 13,
                  color: GroceryAppColors.boxColor1,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(2.0),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _deleteAdderss(String id, int index) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? userid = pref.getString("user_id");
    var map = Map<String, dynamic>();
    map['add_id'] = id;
    map['shop_id'] = GroceryAppConstant.Shop_id;
    map['X-Api-Key'] = GroceryAppConstant.API_KEY;
    map['user_id'] = userid;

    final response = await http.post(
        Uri.parse(
            GroceryAppConstant.base_url + 'manage/api/user_address/delete/'),
        body: map);
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      print(jsonBody);
      OtpModal user = OtpModal.fromJson(jsonDecode(response.body));
      setState(() {
        add.removeAt(index);
      });
//
//      Navigator.push(context,
//                    MaterialPageRoute(builder: (context) => ShowAddress()),);
      showLongToast(user.message ?? "");

//      RegisterModel user = RegisterModel.fromJson(jsonDecode(response.body));
    } else
      throw Exception("Unable to get Employee list");
  }

  showDilogueReviw(BuildContext context, int index) {
    Dialog errorDialog = Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0)), //this right here
      child: Container(
        height: 130.0,
        width: 200.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Do you want to delete!'),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel !',
                      style: TextStyle(color: Colors.red, fontSize: 18.0),
                    )),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();

                      _deleteAdderss(add[index].addId ?? "", index);

//                  Navigator.push(context,
//                    MaterialPageRoute(builder: (context) => ShowAddress()),);
                    },
                    child: Text(
                      'ok !',
                      style: TextStyle(
                          color: GroceryAppColors.success, fontSize: 18.0),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => errorDialog);
  }

  Widget screen() {
    return Center(
      child: InkWell(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 100,
            ),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.0,
                  colors: <Color>[Colors.orange, Colors.deepOrange.shade900],
                  tileMode: TileMode.mirror,
                ).createShader(bounds);
              },
              child: Text(
                "No address found",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                ),
              ),
            ),
//            Text("No address found  ",style: TextStyle(fontSize: 20, color: Colors.black,fontWeight: FontWeight.bold)),
            Container(
              margin: EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GroceryAppColors.telamoredeep,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddAddress(widget.valu)),
                  );
                },
                child: Text(
                  "Add Address",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
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
