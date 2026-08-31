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
    try {
      // CartProvider handles the DummyJSON API call.
      await context
          .read<CartProvider>()
          .addToCart(product);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '${product.title} added to cart!',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to add product to cart.',
          ),
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
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                16.r,
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
                    color:
                        Colors.grey.shade200,
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
            ),

            SizedBox(height: 15.h),

            // Rating.
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),

                SizedBox(width: 5.w),

                CustomText(
                  text:
                      '${product.rating} / 5',
                  fontSize: 14.sp,
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Description.
            CustomText(
              text: 'Description',
              fontSize: 18.sp,
              fontweight:
                  FontWeight.bold,
            ),

            SizedBox(height: 8.h),

            CustomText(
              text:
                  product.description,
              fontSize: 14.sp,
            ),

            SizedBox(height: 20.h),

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
              height: 52.h,
              child:
                  ElevatedButton.icon(
                onPressed: () {
                  _addToCart(
                    context,
                  );
                },

                icon: const Icon(
                  Icons.shopping_cart,
                ),

                label: const Text(
                  'Add to Cart',
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