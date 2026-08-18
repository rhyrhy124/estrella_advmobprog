import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/custom_horizontal_product_card.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_vertical_product_card.dart';

// This screen displays the products available in the shop.
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() =>
      _ProductScreenState();
}

// This state controls the product list and search function.
class _ProductScreenState
    extends State<ProductScreen> {
  // This stores the future result of the products from the API.
  late Future<List<Product>> _productsFuture;

  // This controller is used for the product search field.
  final TextEditingController _searchController =
      TextEditingController();

  // This stores the current search text.
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // This loads the products when the screen starts.
    _productsFuture =
        ProductService().getAllProducts();

    // This updates the search query when the user types.
    _searchController.addListener(() {
      setState(() {
        _searchQuery =
            _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    // This removes the search controller when the screen is closed.
    _searchController.dispose();
    super.dispose();
  }

  // This function loads the products again if there is an error.
  void _retry() {
    setState(() {
      _productsFuture =
          ProductService().getAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // This waits for the product data from the API.
      child: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          // This shows a loading indicator while products are loading.
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // This shows an error message when the products cannot load.
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                    ),

                    SizedBox(height: 10.h),

                    CustomText(
                      text:
                          'Unable to load products.',
                      fontSize: 16.sp,
                      fontweight:
                          FontWeight.bold,
                      textAlign:
                          TextAlign.center,
                    ),

                    SizedBox(height: 8.h),

                    // This displays the error message.
                    CustomText(
                      text:
                          '${snapshot.error}',
                      fontSize: 12.sp,
                      textAlign:
                          TextAlign.center,
                    ),

                    SizedBox(height: 15.h),

                    // This button tries to load the products again.
                    ElevatedButton(
                      onPressed: _retry,
                      child:
                          const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // This gets the products from the API result.
          final products =
              snapshot.data ?? [];

          // This filters the products based on the search text.
          final filteredProducts =
              products.where((product) {
            return product.title
                    .toLowerCase()
                    .contains(_searchQuery) ||
                product.category
                    .toLowerCase()
                    .contains(_searchQuery);
          }).toList();

          // This shows a message when there are no matching products.
          if (filteredProducts.isEmpty) {
            return Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.all(16.r),
                  child: _buildSearchBar(),
                ),

                const Expanded(
                  child: Center(
                    child: Text(
                      'No products found.',
                    ),
                  ),
                ),
              ],
            );
          }

          // This gets the first five products as featured products.
          final featured =
              filteredProducts.take(5).toList();

          // This gets the remaining products for the On Sale section.
          final onSale =
              filteredProducts.length > 5
                  ? filteredProducts
                      .skip(5)
                      .toList()
                  : [];

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16.w,
              8.h,
              16.w,
              20.h,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),

                SizedBox(height: 22.h),

                CustomText(
                  text: 'Hello, Bulldog!',
                  fontSize: 24.sp,
                  fontweight:
                      FontWeight.bold,
                ),

                SizedBox(height: 22.h),

                CustomText(
                  text: 'Featured',
                  fontSize: 20.sp,
                  fontweight:
                      FontWeight.bold,
                ),

                SizedBox(height: 10.h),

                // This displays the featured products horizontally.
                SizedBox(
                  height: 235.h,
                  child: ListView.separated(
                    scrollDirection:
                        Axis.horizontal,
                    itemCount:
                        featured.length,
                    separatorBuilder:
                        (_, __) =>
                            SizedBox(width: 10.w),
                    itemBuilder:
                        (context, index) {
                      return CustomVerticalProductCard(
                        product:
                            featured[index],
                      );
                    },
                  ),
                ),

                SizedBox(height: 25.h),

                CustomText(
                  text: 'On Sale',
                  fontSize: 20.sp,
                  fontweight:
                      FontWeight.bold,
                ),

                SizedBox(height: 10.h),

                // This displays the remaining products.
                ...onSale.map(
                  (product) =>
                      CustomHorizontalProductCard(
                    product: product,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // This creates the search bar used to search products.
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon:
            const Icon(Icons.search),

        // This clear button appears when there is search text.
        suffixIcon:
            _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                    ),
                    onPressed: () {
                      _searchController
                          .clear();
                    },
                  )
                : null,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}