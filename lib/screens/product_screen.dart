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
            final raw =
                snapshot.error
                    .toString();

            String friendly;

            if (raw.contains(
              'SocketException',
            ) ||
                raw.contains(
              'Failed host lookup',
            ) ||
                raw.contains(
              'Network is unreachable',
            )) {
              friendly =
                  'No internet connection. Please check your network and try again.';
            } else if (raw
                    .contains(
              'TimeoutException',
            ) ||
                raw.contains(
              'timed out',
            )) {
              friendly =
                  'The server is taking too long to respond. Please try again.';
            } else {
              friendly =
                  'Unable to load products right now.';
            }

            return Center(
              child: Padding(
                padding: EdgeInsets.all(
                  24.r,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    Icon(
                      Icons
                          .wifi_off_rounded,
                      size: 64.sp,
                      color: Colors
                          .grey
                          .shade400,
                    ),

                    SizedBox(
                        height: 14.h),

                    CustomText(
                      text:
                          'Oops!',
                      fontSize:
                          20.sp,
                      fontweight:
                          FontWeight
                              .bold,
                    ),

                    SizedBox(
                        height: 6.h),

                    CustomText(
                      text:
                          friendly,
                      fontSize:
                          14.sp,
                      textAlign:
                          TextAlign
                              .center,
                    ),

                    SizedBox(
                        height: 18.h),

                    // This button tries to load the products again.
                    ElevatedButton
                        .icon(
                      onPressed:
                          _retry,
                      icon: const Icon(
                        Icons.refresh,
                      ),
                      label: const Text(
                          'Try Again'),
                      style:
                          ElevatedButton
                              .styleFrom(
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12.r,
                          ),
                        ),
                        padding:
                            EdgeInsets
                                .symmetric(
                          horizontal:
                              22.w,
                          vertical:
                              12.h,
                        ),
                      ),
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
                      EdgeInsets.fromLTRB(
                    16.w,
                    8.h,
                    16.w,
                    0,
                  ),
                  child:
                      _buildSearchBar(),
                ),

                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets
                          .all(24.r),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Icon(
                            Icons
                                .search_off_rounded,
                            size: 72.sp,
                            color: Colors
                                .grey
                                .shade400,
                          ),
                          SizedBox(
                              height:
                                  12.h),
                          CustomText(
                            text:
                                'No products found',
                            fontSize:
                                18.sp,
                            fontweight:
                                FontWeight
                                    .bold,
                          ),
                          SizedBox(
                              height:
                                  4.h),
                          CustomText(
                            text:
                                'Try a different search term.',
                            fontSize:
                                13.sp,
                            textAlign:
                                TextAlign
                                    .center,
                          ),
                        ],
                      ),
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

                SizedBox(height: 18.h),

                // Welcome banner card.
                Container(
                  width:
                      double.infinity,
                  padding:
                      EdgeInsets.all(18.r),
                  decoration:
                      BoxDecoration(
                    gradient:
                        LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        )
                            .colorScheme
                            .primary,
                        Theme.of(
                          context,
                        )
                            .colorScheme
                            .primary
                            .withOpacity(
                              0.7,
                            ),
                      ],
                      begin: Alignment
                          .topLeft,
                      end: Alignment
                          .bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      16.r,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      CustomText(
                        text:
                            'Hello, Bulldog!',
                        fontSize:
                            22.sp,
                        fontweight:
                            FontWeight
                                .bold,
                        color: Colors
                            .white,
                      ),
                      SizedBox(
                          height:
                              4.h),
                      CustomText(
                        text:
                            'Discover great deals at Bulldog Market today.',
                        fontSize:
                            12.sp,
                        color: Colors
                            .white70,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 22.h),

                _SectionHeader(
                  title:
                      'Featured',
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
                            SizedBox(width: 12.w),
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

                _SectionHeader(
                  title:
                      'On Sale',
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
        hintStyle: TextStyle(
          fontSize: 13.sp,
        ),
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

        filled: true,
        fillColor: Theme.of(
          context,
        )
            .colorScheme
            .surface
            .withOpacity(
              0.6,
            ),

        contentPadding:
            EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: 12.w,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14.r),
          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14.r),
          borderSide:
              BorderSide.none,
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            )
                .colorScheme
                .primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// Section header with a small accent line
// for Featured and On Sale sections.
class _SectionHeader
    extends StatelessWidget {
  final String title;

  const _SectionHeader({
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration:
              BoxDecoration(
            color: Theme.of(
              context,
            )
                .colorScheme
                .primary,
            borderRadius:
                BorderRadius.circular(
              4.r,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        CustomText(
          text: title,
          fontSize: 19.sp,
          fontweight:
              FontWeight.bold,
        ),
      ],
    );
  }
}