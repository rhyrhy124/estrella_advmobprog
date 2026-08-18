import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';

// This screen displays the user's profile and related items.
class ProfileScreen
    extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

// This state controls the profile screen data.
class _ProfileScreenState
    extends State<ProfileScreen> {
  // This stores the future result of the products.
  late Future<List<Product>>
      _productsFuture;

  @override
  void initState() {
    super.initState();

    // This loads the products for the recommendations.
    _productsFuture =
        ProductService().getAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding:
          EdgeInsets.all(16.r),

      child: Column(
        children: [
          // This displays the user's profile icon.
          CircleAvatar(
            radius: 45.r,
            backgroundColor:
                Colors.deepPurple.shade100,

            child: Icon(
              Icons.person,
              size: 50.sp,
            ),
          ),

          SizedBox(height: 12.h),

          // This displays the user's name.
          CustomText(
            text:
                'Rhyza Ann H. Estrella',
            fontSize: 19.sp,
            fontweight:
                FontWeight.bold,
          ),

          // This displays the user's coins.
          CustomText(
            text: 'Coins: 1500',
            fontSize: 13.sp,
          ),

          SizedBox(height: 25.h),

          // This displays the My Items section title.
          Align(
            alignment:
                Alignment.centerLeft,

            child: CustomText(
              text: 'My Items',
              fontSize: 19.sp,
              fontweight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(height: 10.h),

          // These boxes show the different order statuses.
          Row(
            children: [
              _orderBox(
                Icons.account_balance_wallet,
                'To Pay',
              ),

              _orderBox(
                Icons.local_shipping,
                'To Ship',
              ),

              _orderBox(
                Icons.inventory,
                'To Receive',
              ),
            ],
          ),

          SizedBox(height: 25.h),

          // This displays the recommendation section title.
          Align(
            alignment:
                Alignment.centerLeft,

            child: CustomText(
              text:
                  'Recommended for you',
              fontSize: 19.sp,
              fontweight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(height: 12.h),

          // This loads the recommended products.
          FutureBuilder<List<Product>>(
            future: _productsFuture,

            builder:
                (context, snapshot) {
              // This shows a loading indicator while products are loading.
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              // This shows a message when the products cannot load.
              if (snapshot.hasError) {
                return const Text(
                  'Unable to load recommendations.',
                );
              }

              // This gets the first two products for recommendations.
              final products =
                  snapshot.data
                          ?.take(2)
                          .toList() ??
                      [];

              return Row(
                children: products
                    .map(
                      (product) =>
                          Expanded(
                        child: Container(
                          margin:
                              EdgeInsets.only(
                            right: 6.w,
                          ),

                          child: Column(
                            children: [
                              // This displays the product image.
                              Image.network(
                                product.thumbnail,
                                height: 90.h,

                                // This shows an icon when the image cannot load.
                                errorBuilder:
                                    (_, __, ___) {
                                  return SizedBox(
                                    height: 90.h,
                                    child:
                                        const Icon(
                                      Icons
                                          .image_outlined,
                                    ),
                                  );
                                },
                              ),

                              // This displays the product name.
                              CustomText(
                                text:
                                    product.title,
                                fontSize:
                                    13.sp,
                                fontweight:
                                    FontWeight.bold,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),

                              // This displays the product price.
                              CustomText(
                                text:
                                    '₱${product.price.toStringAsFixed(0)}',
                                fontSize:
                                    12.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // This creates one order status box.
  Widget _orderBox(
    IconData icon,
    String label,
  ) {
    return Expanded(
      child: Container(
        margin:
            EdgeInsets.symmetric(
          horizontal: 3.w,
        ),

        padding:
            EdgeInsets.symmetric(
          vertical: 15.h,
        ),

        decoration:
            BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surface,

          borderRadius:
              BorderRadius.circular(
            10.r,
          ),
        ),

        child: Column(
          children: [
            Icon(icon),

            SizedBox(height: 5.h),

            CustomText(
              text: label,
              fontSize: 11.sp,
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}