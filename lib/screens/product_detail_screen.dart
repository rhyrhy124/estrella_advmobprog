import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_text.dart';

// This screen displays the details of a selected product.
class ProductDetailScreen
    extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  // This adds the selected product to the cart.
  Future<void> _addToCart(
    BuildContext context,
  ) async {
    final messenger =
        ScaffoldMessenger.of(context);

    try {
      // CartProvider handles the DummyJSON API call.
      await context
          .read<CartProvider>()
          .addToCart(product);

      if (!context.mounted) {
        return;
      }

      messenger
          .hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${product.title} added to cart!',
          ),
          behavior: SnackBarBehavior
              .floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      final raw =
          e.toString();

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
            'No internet connection. Please try again.';
      } else if (raw.contains(
        'TimeoutException',
      ) ||
          raw.contains(
        'timed out',
      )) {
        friendly =
            'The server is taking too long. Please try again.';
      } else {
        friendly =
            'Failed to add product to cart. Please try again.';
      }

      messenger
          .hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            friendly,
          ),
          behavior: SnackBarBehavior
              .floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Product Details',
        ),
      ),

      body: SingleChildScrollView(
        padding:
            EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Product image.
            Container(
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  18.r,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(
                        0.08,
                      ),
                    blurRadius: 12,
                    offset:
                        const Offset(
                      0,
                      4,
                    ),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  18.r,
                ),
                child: Image.network(
                  product.thumbnail,
                  width:
                      double.infinity,
                  height: 280.h,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) {
                    return Container(
                      width:
                          double.infinity,
                      height: 280.h,
                      color: Colors
                          .grey
                          .shade200,
                      child:
                          const Icon(
                        Icons
                            .image_outlined,
                        size: 60,
                      ),
                    );
                  },
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
                      height: 280.h,
                      child:
                          const Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Product title.
            CustomText(
              text:
                  product.title,
              fontSize: 24.sp,
              fontweight:
                  FontWeight.bold,
            ),

            SizedBox(height: 8.h),

            // Product price.
            CustomText(
              text:
                  '₱${product.price.toStringAsFixed(2)}',
              fontSize: 22.sp,
              fontweight:
                  FontWeight.bold,
              color: Theme.of(
                context,
              )
                  .colorScheme
                  .primary,
            ),

            SizedBox(height: 12.h),

            // Rating.
            Container(
              padding:
                  EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 6.h,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.amber
                    .withOpacity(0.15),
                borderRadius:
                    BorderRadius.circular(
                  20.r,
                ),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color:
                        Colors.amber,
                    size: 18,
                  ),

                  SizedBox(width: 4.w),

                  CustomText(
                    text:
                        '${product.rating} / 5',
                    fontSize: 13.sp,
                    fontweight:
                        FontWeight
                            .w600,
                  ),
                ],
              ),
            ),

            SizedBox(height: 22.h),

            // Description.
            CustomText(
              text: 'Description',
              fontSize: 17.sp,
              fontweight:
                  FontWeight.bold,
            ),

            SizedBox(height: 8.h),

            CustomText(
              text:
                  product.description,
              fontSize: 14.sp,
            ),

            SizedBox(height: 22.h),

            _InfoRow(
              label: 'Category',
              value:
                  product.category,
            ),

            _InfoRow(
              label: 'Brand',
              value:
                  product.brand,
            ),

            _InfoRow(
              label: 'Stock',
              value:
                  '${product.stock}',
            ),

            _InfoRow(
              label: 'Status',
              value:
                  product
                      .availabilityStatus,
            ),

            _InfoRow(
              label: 'Shipping',
              value:
                  product
                      .shippingInformation,
            ),

            _InfoRow(
              label: 'Return Policy',
              value:
                  product.returnPolicy,
            ),

            SizedBox(height: 25.h),

            // Add to Cart button.
            SizedBox(
              width:
                  double.infinity,
              height: 54.h,
              child:
                  ElevatedButton.icon(
                onPressed: () {
                  _addToCart(
                    context,
                  );
                },

                icon: const Icon(
                  Icons
                      .shopping_cart_outlined,
                  color:
                      Colors.white,
                ),

                label: const Text(
                  'Add to Cart',
                  style:
                      TextStyle(
                    fontFamily:
                        'Poppins',
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Colors.white,
                    letterSpacing:
                        0.5,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(
                    context,
                  )
                          .colorScheme
                          .primary,
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      14.r,
                    ),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// This widget displays one product information row.
class _InfoRow
    extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          EdgeInsets.symmetric(
        vertical: 6.h,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105.w,
            child: Text(
              label,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 