import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/auth_provider.dart';
import '../providers/home_data_provider.dart';
import '../models/restaurant_model.dart';
import '../models/promotional_banner_model.dart';
import 'login_screen.dart';

class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({super.key});

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
  final PageController _bannerController = PageController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeDataProvider>().initializeData();
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<HomeDataProvider>().refreshData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildPromotionalBanner(),
                      _buildRestaurantsSection(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // User Profile Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Colors.orange,
                    child: Text(
                      user?.displayName?.substring(0, 1).toUpperCase() ??
                          user?.email?.substring(0, 1).toUpperCase() ??
                          'U',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.grey[400],
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Tankariyapanth, Ujjain...',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showSignOutDialog(context),
                    icon: Icon(Icons.logout, color: Colors.white, size: 24.sp),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Search Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[600], size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Type your cravings here..',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16.sp,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          context.read<HomeDataProvider>().updateSearchQuery(
                            value,
                          );
                        },
                      ),
                    ),
                    Icon(Icons.mic, color: Colors.grey[600], size: 20.sp),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPromotionalBanner() {
    return Consumer<HomeDataProvider>(
      builder: (context, homeProvider, child) {
        if (homeProvider.banners.isEmpty) {
          return SizedBox(height: 20.h);
        }

        return Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              height: 160.h,
              child: PageView.builder(
                controller: _bannerController,
                onPageChanged: (index) {
                  homeProvider.updateBannerIndex(index);
                },
                itemCount: homeProvider.banners.length,
                itemBuilder: (context, index) {
                  final banner = homeProvider.banners[index];
                  return _buildBannerCard(banner);
                },
              ),
            ),
            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                homeProvider.banners.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: homeProvider.currentBannerIndex == index ? 12.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: homeProvider.currentBannerIndex == index
                        ? Colors.orange
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBannerCard(PromotionalBannerModel banner) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.asset(
          banner.imageUrl,
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildRestaurantsSection() {
    return Consumer<HomeDataProvider>(
      builder: (context, homeProvider, child) {
        if (homeProvider.isLoading) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.h),
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          );
        }

        if (homeProvider.filteredRestaurants.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.h),
              child: Text(
                'No restaurants found',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'Restaurants near you',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Restaurant cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: homeProvider.filteredRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = homeProvider.filteredRestaurants[index];
                return _buildRestaurantCard(restaurant);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRestaurantCard(RestaurantModel restaurant) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with favorite button
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
                child: Image.asset(
                  restaurant.imageUrl,
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // Favorite button
              Positioned(
                top: 12.h,
                right: 12.w,
                child: GestureDetector(
                  onTap: () {
                    context.read<HomeDataProvider>().toggleRestaurantFavorite(
                      restaurant.id,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      restaurant.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: restaurant.isFavorite
                          ? Colors.red
                          : Colors.grey[600],
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Restaurant info
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        restaurant.cuisine,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating and delivery time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          restaurant.rating.toString(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${restaurant.deliveryTime} min',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', true),
              _buildNavItem(Icons.shopping_bag_outlined, 'Orders', false),
              _buildNavItem(Icons.person_outline, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.black : Colors.grey[600],
          size: 24.sp,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey[600],
            fontSize: 12.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}
