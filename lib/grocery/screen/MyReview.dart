import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:EcoShine24/grocery/General/AppConstant.dart';
import 'package:EcoShine24/grocery/dbhelper/database_helper.dart';
import 'package:EcoShine24/grocery/model/MyReviewModel.dart';
import 'package:EcoShine24/grocery/screen/detailpage1.dart';

class MyReview extends StatefulWidget {
  @override
  _TrackOrderState createState() => _TrackOrderState();
}

class _TrackOrderState extends State<MyReview> {
  String selectedFilter = 'All';

  Future<void> getUserInfo() async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    final String? userid = pre.getString("user_id");
    if (!mounted) return;
    setState(() {
      GroceryAppConstant.user_id = userid ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GroceryAppColors.bg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              GroceryAppColors.tela,
              GroceryAppColors.tela1,
              GroceryAppColors.bg,
            ],
            stops: [0.0, 0.22, 0.22],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: FutureBuilder<List<Review>?>(
                  future: myReview(GroceryAppConstant.user_id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: GroceryAppColors.white,
                        ),
                      );
                    }

                    final List<Review> reviews = snapshot.data ?? [];
                    if (reviews.isEmpty) {
                      return _buildEmptyState();
                    }

                    final List<Review> filteredReviews =
                        _filterReviews(reviews, selectedFilter);

                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16, 10, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCard(reviews),
                          SizedBox(height: 16),
                          _buildFilterRow(reviews),
                          SizedBox(height: 16),
                          if (filteredReviews.isEmpty)
                            _buildNoFilterResultCard()
                          else
                            ...filteredReviews.map(
                              (review) => _buildReviewCard(context, review),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: GroceryAppColors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: GroceryAppColors.white.withOpacity(0.18),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: GroceryAppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: GroceryAppColors.tela,
                  size: 18,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  "My Reviews",
                  style: TextStyle(
                    color: GroceryAppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: GroceryAppColors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.rate_review_rounded,
                color: GroceryAppColors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(List<Review> reviews) {
    final double average = _averageRating(reviews);
    final Map<int, int> buckets = _ratingBuckets(reviews);

    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: GroceryAppColors.tela.withOpacity(0.10),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Review Summary",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: GroceryAppColors.tela,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GroceryAppColors.tela,
                      GroceryAppColors.tela1,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      average.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Icon(Icons.star_rounded, color: Colors.amberAccent),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    RatingBarIndicator(
                      rating: average,
                      itemBuilder: (context, index) => Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 22,
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${reviews.length} review${reviews.length == 1 ? '' : 's'} from completed services",
                        style: TextStyle(
                          color: GroceryAppColors.tela1,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    ...[5, 4, 3].map(
                      (star) => Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: _buildRatingBar(
                          star,
                          buckets[star] ?? 0,
                          reviews.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, int count, int total) {
    final double progress = total == 0 ? 0 : count / total;
    return Row(
      children: [
        SizedBox(
          width: 34,
          child: Text(
            "$star★",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: GroceryAppColors.tela,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: GroceryAppColors.bg,
              valueColor: AlwaysStoppedAnimation<Color>(
                GroceryAppColors.tela1,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Text(
          "$count",
          style: TextStyle(
            color: GroceryAppColors.tela1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow(List<Review> reviews) {
    final filters = ["All", "5★", "4★", "3★ or less"];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final bool isSelected = selectedFilter == filter;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? GroceryAppColors.tela : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? GroceryAppColors.tela
                      : GroceryAppColors.tela.withOpacity(0.18),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: GroceryAppColors.tela.withOpacity(0.22),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  _filterLabel(filter, reviews),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : GroceryAppColors.tela,
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 10),
        itemCount: filters.length,
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Review item) {
    final double rating = double.tryParse(item.stars ?? "0") ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: GroceryAppColors.tela.withOpacity(0.08),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetails1(item.product ?? ""),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          GroceryAppColors.tela.withOpacity(0.14),
                          GroceryAppColors.tela1.withOpacity(0.10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.verified_outlined,
                      color: GroceryAppColors.tela,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName?.isNotEmpty == true
                              ? item.productName!
                              : "Service Review",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: GroceryAppColors.tela,
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: rating,
                              itemBuilder: (context, index) => Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "${rating.toStringAsFixed(1)} / 5",
                              style: TextStyle(
                                color: GroceryAppColors.tela1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: GroceryAppColors.bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      item.dates ?? "",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: GroceryAppColors.tela1,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GroceryAppColors.bg.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: GroceryAppColors.tela.withOpacity(0.08),
                  ),
                ),
                child: ReadMoreText(
                  item.review?.trim().isNotEmpty == true
                      ? item.review!
                      : "No written feedback shared for this service.",
                  trimLines: 3,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: ' Read more',
                  trimExpandedText: ' Show less',
                  colorClickableText: GroceryAppColors.tela,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                  moreStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: GroceryAppColors.tela,
                  ),
                  lessStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: GroceryAppColors.tela,
                  ),
                ),
              ),
              SizedBox(height: 14),
              Row(
                children: [
                  _buildTag("Verified Booking"),
                  SizedBox(width: 8),
                  _buildTag(_experienceLabel(rating)),
                  Spacer(),
                  Text(
                    "View Service",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: GroceryAppColors.tela,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: GroceryAppColors.tela.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: GroceryAppColors.tela,
        ),
      ),
    );
  }

  Widget _buildNoFilterResultCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(
            Icons.filter_alt_off_rounded,
            size: 42,
            color: GroceryAppColors.tela1,
          ),
          SizedBox(height: 12),
          Text(
            "No reviews match this filter",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: GroceryAppColors.tela,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Try another rating filter to explore your past feedback.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GroceryAppColors.tela1,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(24),
        padding: EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: GroceryAppColors.tela.withOpacity(0.08),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: GroceryAppColors.bg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rate_review_outlined,
                size: 50,
                color: GroceryAppColors.tela,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "No Reviews Yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: GroceryAppColors.tela,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "You haven't written any reviews yet.\nComplete a service and share your experience here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: GroceryAppColors.tela1,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: GroceryAppColors.tela,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                "Back to Services",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Review> _filterReviews(List<Review> reviews, String filter) {
    switch (filter) {
      case '5★':
        return reviews.where((item) => _roundedRating(item) == 5).toList();
      case '4★':
        return reviews.where((item) => _roundedRating(item) == 4).toList();
      case '3★ or less':
        return reviews.where((item) => _roundedRating(item) <= 3).toList();
      default:
        return reviews;
    }
  }

  String _filterLabel(String filter, List<Review> reviews) {
    if (filter == 'All') {
      return "All (${reviews.length})";
    }
    return filter;
  }

  int _roundedRating(Review item) {
    return (double.tryParse(item.stars ?? "0") ?? 0).round();
  }

  double _averageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0;
    final double total = reviews.fold(
      0,
      (sum, item) => sum + (double.tryParse(item.stars ?? "0") ?? 0),
    );
    return total / reviews.length;
  }

  Map<int, int> _ratingBuckets(List<Review> reviews) {
    final Map<int, int> buckets = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final review in reviews) {
      final int rating = _roundedRating(review).clamp(1, 5);
      buckets[rating] = (buckets[rating] ?? 0) + 1;
    }
    return buckets;
  }

  String _experienceLabel(double rating) {
    if (rating >= 4.5) return "Excellent";
    if (rating >= 4.0) return "Very Good";
    if (rating >= 3.0) return "Good";
    return "Needs Improvement";
  }
}
