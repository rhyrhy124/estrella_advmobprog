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
                        .shopping_bag_outlined,
                    size: 96.sp,
                    color: Colors
                        .grey
                        .shade400,
                  ),
                  SizedBox(
                      height: 14.h),
                  CustomText(
                    text:
                        'Your cart is empty',
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
                        'Browse the shop and add items to your cart.',
                    fontSize:
                        13.sp,
                    textAlign:
                        TextAlign
                            .center,
                  ),
                ],
              ),
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
                      bottom: 12.h,
                    ),

                    padding:
                        EdgeInsets.all(12.r),

                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        14.r,
                      ),

                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .surface,

                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black
                              .withOpacity(
                            0.05,
                          ),
                          blurRadius:
                              8,
                          offset:
                              const Offset(
                            0,
                            3,
                          ),
                        ),
                      ],
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
                                    '₱${product.price.toStringAsFixed(2)}',

                                fontSize:
                                    14.sp,

                                fontweight:
                                    FontWeight.bold,
                              ),

                              SizedBox(
                                height: 6.h,
                              ),

                              // Quantity controls.
                              Row(
                                children: [
                                  _QtyButton(
                                    icon:
                                        Icons.remove,
                                    onPressed:
                                        () {
                                      context
                                          .read<
                                              CartProvider>()
                                          .decreaseQuantity(
                                            product.id,
                                          );
                                    },
                                  ),

                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(
                                      horizontal:
                                          10.w,
                                    ),
                                    child:
                                        CustomText(
                                      text:
                                          '${product.quantity}',
                                      fontSize:
                                          13.sp,
                                      fontweight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),

                                  _QtyButton(
                                    icon:
                                        Icons.add,
                                    onPressed:
                                        () {
                                      context
                                          .read<
                                              CartProvider>()
                                          .increaseQuantity(
                                            product.id,
                                          );
                                    },
                                  ),
                                ],
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
            Container(
              margin: EdgeInsets.fromLTRB(
                16.w,
                8.h,
                16.w,
                8.h,
              ),
              padding:
                  EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              decoration:
                  BoxDecoration(
                color: Theme.of(
                  context,
                )
                    .colorScheme
                    .primary
                    .withOpacity(
                      0.08,
                    ),
                borderRadius:
                    BorderRadius.circular(
                  14.r,
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      CustomText(
                        text:
                            'Total',
                        fontSize:
                            13.sp,
                        color: Colors
                            .grey
                            .shade700,
                      ),
                      SizedBox(
                          height:
                              2.h),
                      CustomText(
                        text:
                            '${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}',
                        fontSize:
                            11.sp,
                        color: Colors
                            .grey
                            .shade600,
                      ),
                    ],
                  ),
                  CustomText(
                    text:
                        '₱${cart.total.toStringAsFixed(2)}',
                    fontSize:
                        22.sp,
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
                height: 54.h,

                child:
                    ElevatedButton.icon(
                  onPressed:
                      _confirmOrder,

                  icon: const Icon(
                    Icons
                        .check_circle_outline,
                    color:
                        Colors.white,
                  ),

                  label: const Text(
                    'Confirm Order',
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
                    elevation:
                        2,
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

// Small circular button used for the quantity +/−
// controls in the cart item row.
class _QtyButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QtyButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Theme.of(
        context,
      )
          .colorScheme
          .primary
          .withOpacity(
            0.1,
          ),
      shape:
          const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder:
            const CircleBorder(),
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: Icon(
            icon,
            size: 18.sp,
            color: Theme.of(
              context,
            )
                .colorScheme
                .primary,
          ),
        ),
      ),
    );
  }
}