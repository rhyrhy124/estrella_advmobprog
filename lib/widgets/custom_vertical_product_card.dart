import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import 'custom_text.dart';

// This widget displays a product in a vertical card.
class CustomVerticalProductCard
    extends StatelessWidget {
  final Product product;

  // This constructor receives the product to display.
  const CustomVerticalProductCard({
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
        width: 150.w,
        padding: EdgeInsets.all(8.r),

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

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(10.r),

                // This displays the product image.
                child: Image.network(
                  product.thumbnail,
                  width: double.infinity,
                  fit: BoxFit.cover,

                  // This displays an icon when the image cannot load.
                  errorBuilder:
                      (_, __, ___) {
                    return Container(
                      color: Colors
                          .grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons
                              .image_outlined,
                          size: 32,
                        ),
                      ),
                    );
                  },

                  // This displays a loading indicator while the image loads.
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

                    return const Center(
                      child:
                          CircularProgressIndicator(
                        strokeWidth:
                            2,
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // This displays the product title.
            CustomText(
              text: product.title,
              fontSize: 13.sp,
              fontweight:
                  FontWeight.bold,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
            ),

            SizedBox(height: 2.h),

            // This displays the product price.
            CustomText(
              text:
                  '₱${product.price.toStringAsFixed(2)}',
              fontSize: 12.sp,
              fontweight:
                  FontWeight.w600,
              color: Theme.of(
                context,
              )
                  .colorScheme
                  .primary,
            ),
          ],
        ),
      ),
    );
  }
}