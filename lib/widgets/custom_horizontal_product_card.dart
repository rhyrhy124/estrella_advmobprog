import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import 'custom_text.dart';

// This widget displays a product in a horizontal card.
class CustomHorizontalProductCard
    extends StatelessWidget {
  final Product product;

  // This constructor receives the product to display.
  const CustomHorizontalProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // This opens the product details when the card is tapped.
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailScreen(
              product: product,
            ),
          ),
        );
      },

      child: Container(
        margin:
            EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.r),

        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surface,
          borderRadius:
              BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(
                0,
                3,
              ),
            ),
          ],
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(10.r),

              // This displays the product thumbnail.
              child: Image.network(
                product.thumbnail,
                width: 80.w,
                height: 80.h,
                fit: BoxFit.cover,

                // This displays an icon if the image cannot load.
                errorBuilder:
                    (_, __, ___) {
                  return Container(
                    width: 80.w,
                    height: 80.h,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_outlined,
                    ),
                  );
                },

                // This shows a loading indicator while the image loads.
                loadingBuilder:
                    (
                      context,
                      child,
                      loadingProgress,
                    ) {
                  if (loadingProgress ==
                      null) {
                    return child;
                  }

                  return SizedBox(
                    width: 80.w,
                    height: 80.h,
                    child: const Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // This displays the product title.
                  CustomText(
                    text: product.title,
                    fontSize: 15.sp,
                    fontweight:
                        FontWeight.bold,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4.h),

                  // This displays the product category.
                  CustomText(
                    text: product.category
                        .toUpperCase(),
                    fontSize: 10.sp,
                    letterSpacing: 0.5,
                    color: Colors
                        .grey.shade600,
                  ),

                  SizedBox(height: 6.h),

                  // This displays the product price.
                  CustomText(
                    text:
                        '₱${product.price.toStringAsFixed(2)}',
                    fontSize: 15.sp,
                    fontweight:
                        FontWeight.bold,
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}