import 'package:flutter/material.dart';

class CustomAppBar extends PreferredSize {
  final double? height;

  CustomAppBar(this.height,
      {required super.child, required super.preferredSize});

  @override
  Size get preferredSize => Size.fromHeight(height!);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      height: preferredSize.height,
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        child: Material(
          color: Color(0xFFBBDEFB), // light blue background
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Color(0xFF1976D2), // blue border
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: TextField(
                style: TextStyle(
                  color: Color(0xFF1976D2), // blue text
                ),
                decoration: InputDecoration(
                  hintText: 'Search Your Product',
                  hintStyle:
                      TextStyle(color: Color(0xFF42A5F5)), // lighter blue
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF1976D2), // blue icon
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
