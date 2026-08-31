import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/custom_text.dart';

// This screen displays the user's cart.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() =>
      _CartScreenState();
}

class _CartScreenState
    extends State<CartScreen> {
  @override
  void initState() {
    super.initState();

    // Only fetch the cart from the API if the local
    // cart has never been loaded. The DummyJSON
    // /carts/user/{id} endpoint returns static demo
    // carts and would overwrite products added via
    // POST /carts/add during this session.
    Future.microtask(
      () {
        final cart =
            context.read<CartProvider>();

        if (cart.cart == null) {
          cart.loadCart();
        }
      },
    );
  }

  // This confirms the order.
  void _confirmOrder() {
    final cart =
        context.read<CartProvider>();

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Your cart is empty.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Order confirmed successfully!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (
        context,
        cart,
        child,
      ) {
        // Show loading only if the cart has not
        // been initialized yet.
        if (cart.cart == null) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        // Show empty cart message.
        if (cart.items.isEmpty) {
          return const Center(
            child: Text(
              'Your cart is empty.',
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding:
                    EdgeInsets.all(16.r),

                itemCount:
                    cart.items.length,

                itemBuilder:
                    (context, index) {
                  final product =
                      cart.items[index];

                  return Container(
                    margin:
                        EdgeInsets.only(
                      bottom: 10.h,
                    ),

                    padding:
                        EdgeInsets.all(10.r),

                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        12.r,
                      ),

                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .surface,
                    ),

                    child: Row(
                      children: [
                        // Product image.
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            8.r,
                          ),

                          child:
                              Image.network(
                            product.thumbnail,

                            width: 75.w,
                            height: 75.h,

                            fit: BoxFit.cover,

                            errorBuilder:
                                (_, __, ___) {
                              return Container(
                                width: 75.w,
                                height: 75.h,

                                color: Colors
                                    .grey
                                    .shade200,

                                child:
                                    const Icon(
                                  Icons
                                      .image_outlined,
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(width: 12.w),

                        // Product information.
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              CustomText(
                                text:
                                    product.title,

                                fontSize:
                                    15.sp,

                                fontweight:
                                    FontWeight.bold,

                                maxLines: 1,

                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),

                              SizedBox(
                                height: 4.h,
                              ),

                              CustomText(
                                text:
                                    'Quantity: ${product.quantity}',

                                fontSize:
                                    12.sp,
                              ),

                              SizedBox(
                                height: 4.h,
                              ),

                              CustomText(
                                text:
                                    '₱${product.price.toStringAsFixed(2)}',

                                fontSize:
                                    14.sp,

                                fontweight:
                                    FontWeight.bold,
                              ),

                              SizedBox(
                                height: 4.h,
                              ),

                              CustomText(
                                text:
                                    'Subtotal: ₱${product.total.toStringAsFixed(2)}',

                                fontSize:
                                    12.sp,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Cart total.
            Padding(
              padding:
                  EdgeInsets.fromLTRB(
                16.r,
                8.r,
                16.r,
                8.r,
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [
                  CustomText(
                    text: 'Total',

                    fontSize: 18.sp,

                    fontweight:
                        FontWeight.bold,
                  ),

                  CustomText(
                    text:
                        '₱${cart.total.toStringAsFixed(2)}',

                    fontSize: 18.sp,

                    fontweight:
                        FontWeight.bold,
                  ),
                ],
              ),
            ),

            // Confirm Order button.
            Padding(
              padding:
                  EdgeInsets.fromLTRB(
                16.w,
                4.h,
                16.w,
                16.h,
              ),

              child: SizedBox(
                width: double.infinity,
                height: 52.h,

                child:
                    ElevatedButton.icon(
                  onPressed:
                      _confirmOrder,

                  icon: const Icon(
                    Icons.check_circle_outline,
                  ),

                  label: const Text(
                    'Confirm Order',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}