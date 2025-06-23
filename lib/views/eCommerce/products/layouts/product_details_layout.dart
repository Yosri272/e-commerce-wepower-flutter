import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ready_ecommerce/components/ecommerce/app_logo.dart';
import 'package:ready_ecommerce/components/ecommerce/confirmation_dialog.dart';
import 'package:ready_ecommerce/components/ecommerce/custom_button.dart';
import 'package:ready_ecommerce/components/ecommerce/custom_cart.dart';
import 'package:ready_ecommerce/components/ecommerce/custom_transparent_button.dart';
import 'package:ready_ecommerce/config/app_color.dart';
import 'package:ready_ecommerce/config/app_constants.dart';
import 'package:ready_ecommerce/config/theme.dart';
import 'package:ready_ecommerce/controllers/common/master_controller.dart';
import 'package:ready_ecommerce/controllers/eCommerce/cart/cart_controller.dart';
import 'package:ready_ecommerce/controllers/eCommerce/product/product_controller.dart';
import 'package:ready_ecommerce/controllers/eCommerce/shop/shop_controller.dart';
import 'package:ready_ecommerce/controllers/misc/misc_controller.dart';
import 'package:ready_ecommerce/generated/l10n.dart';
import 'package:ready_ecommerce/models/eCommerce/cart/add_to_cart_model.dart';
import 'package:ready_ecommerce/models/eCommerce/cart/hive_cart_model.dart';
import 'package:ready_ecommerce/models/eCommerce/order/order_now_cart_model.dart';
import 'package:ready_ecommerce/models/eCommerce/product/product_details.dart';
import 'package:ready_ecommerce/routes.dart';
import 'package:ready_ecommerce/services/common/hive_service_provider.dart';
import 'package:ready_ecommerce/utils/context_less_navigation.dart';
import 'package:ready_ecommerce/utils/global_function.dart';
import 'package:ready_ecommerce/views/eCommerce/products/components/product_color_picker.dart';
import 'package:ready_ecommerce/views/eCommerce/products/components/product_description.dart';
import 'package:ready_ecommerce/views/eCommerce/products/components/product_details_and_review.dart';
import 'package:ready_ecommerce/views/eCommerce/products/components/product_image_page_view.dart';
import 'package:ready_ecommerce/views/eCommerce/products/components/product_size_picker.dart';
import 'package:ready_ecommerce/views/eCommerce/products/components/shop_info.dart';
import 'package:ready_ecommerce/views/eCommerce/products/components/similar_products_widget.dart';

class EcommerceProductDetailsLayout extends ConsumerStatefulWidget {
  final int productId;
  const EcommerceProductDetailsLayout({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<EcommerceProductDetailsLayout> createState() =>
      _EcommerceProductDetailsLayoutState();
}

class _EcommerceProductDetailsLayoutState
    extends ConsumerState<EcommerceProductDetailsLayout> {
  bool isTextExpanded = false;
  bool isFavorite = false;
  bool isLoading = false;
  // change the status bar color to transparent

  @override
  Widget build(BuildContext context) {
    return LoadingWrapperWidget(
      isLoading: ref.watch(cartController).isLoading,
      child: Scaffold(
        backgroundColor: colors(context).accentColor,
        // appBar: AppBar(
        //   leading: IconButton(
        //     onPressed: () {
        //       ref.read(shopControllerProvider.notifier).review.clear();
        //       context.nav.pop();
        //     },
        //     icon: const Icon(Icons.arrow_back),
        //   ),
        //   surfaceTintColor: Theme.of(context).scaffoldBackgroundColor ==
        //           EcommerceAppColor.black
        //       ? colors(context).dark
        //       : colors(context).light,
        //   title: const Text(''),
        //   actions: [
        //     _buildAppBarRightRow(context: context),
        //   ],
        // ),
        bottomNavigationBar: ref
            .watch(productDetailsControllerProvider(widget.productId))
            .whenOrNull(
              data: (productDetails) => _buildBottomNavigationBar(
                  context: context, productDetails: productDetails),
            ),
        body: Stack(
          children: [
            ref.watch(productDetailsControllerProvider(widget.productId)).when(
                  data: (productDetails) => SingleChildScrollView(
                    child: AnimationLimiter(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 500),
                          childAnimationBuilder: (widget) => SlideAnimation(
                              verticalOffset: 50.h,
                              child: FadeInAnimation(
                                child: widget,
                              )),
                          children: [
                            Gap(2.h),
                            ProductImagePageView(
                                productDetails: productDetails),
                            Gap(14.h),
                            ProductDescription(productDetails: productDetails),
                            Gap(14.h),
                            Visibility(
                              visible: productDetails.product.colors.isNotEmpty,
                              child: ProductColorPicker(
                                  productDetails: productDetails),
                            ),
                            Gap(14.h),
                            Visibility(
                              visible: productDetails
                                  .product.productSizeList.isNotEmpty,
                              child: ProductSizePicker(
                                  productDetails: productDetails),
                            ),
                            Visibility(
                              visible: ref
                                  .read(masterControllerProvider.notifier)
                                  .materModel
                                  .data
                                  .isMultiVendor,
                              child: Gap(14.h),
                            ),
                            Visibility(
                                visible: ref
                                    .read(masterControllerProvider.notifier)
                                    .materModel
                                    .data
                                    .isMultiVendor,
                                child: ShopInformation(
                                    productDetails: productDetails)),
                            Gap(14.h),
                            ProductDetailsAndReview(
                              productDetails: productDetails,
                            ),
                            Gap(14.h),
                            SimilarProductsWidget(
                              productDetails: productDetails,
                            ),
                            Gap(14.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                  error: ((error, stackTrace) => Center(
                        child: Text(
                          error.toString(),
                        ),
                      )),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(top: 26, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: IconButton(
                        onPressed: () {
                          ref
                              .read(shopControllerProvider.notifier)
                              .review
                              .clear();
                          context.nav.pop();
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: colors(context).primaryColor,
                        ),
                      ),
                    ),
                    _buildAppBarRightRow(context: context),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildAppBarRightRow({required BuildContext context}) {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.only(right: 20.w, bottom: 6.h),
        child: Row(
          children: [
            CustomCartWidget(context: context),
            // Gap(10.w),
            // SvgPicture.asset(
            //   Assets.svg.share,
            //   width: 52.w,
            // )
          ],
        ),
      ),
    );
  }

  _buildBottomNavigationBar(
      {required BuildContext context, required ProductDetails productDetails}) {
    return ValueListenableBuilder<Box<HiveCartModel>>(
      valueListenable:
          Hive.box<HiveCartModel>(AppConstants.cartModelBox).listenable(),
      builder: (context, cartBox, _) {
        final cartItems = cartBox.values.toList();
        for (int i = 0; i < cartItems.length; i++) {
          final cartProduct = cartItems[i];
          if (cartProduct.productId == productDetails.product.id) {
            break;
          }
        }
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          height: 70.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: CustomTransparentButton(
                    buttonTextColor: EcommerceAppColor.primary,
                    borderColor: EcommerceAppColor.primary,
                    buttonText: S.of(context).addToCart,
                    onTap: () {
                      final AddToCartModel addToCartModel = AddToCartModel(
                        productId: productDetails.product.id,
                        quantity: 1,
                        size: productDetails.product.productSizeList.isNotEmpty
                            ? productDetails
                                .product
                                .productSizeList[
                                    ref.read(selectedProductSizeIndex)]
                                .name
                            : null,
                        color: productDetails.product.colors.isNotEmpty
                            ? productDetails
                                .product
                                .colors[ref.read(selectedProductColorIndex)!]
                                .name
                            : null,
                      );
                      if (!ref.read(hiveServiceProvider).userIsLoggedIn()) {
                        _showTheWarningDialog();
                      } else {
                        ref
                            .read(cartController.notifier)
                            .addToCart(addToCartModel: addToCartModel);
                      }
                    },
                  ),
                ),
                Gap(10.w),
                Flexible(
                  flex: 1,
                  child: CustomButton(
                    buttonText: S.of(context).buyNow,
                    onPressed: () {
                      final OrderNowCartModel orderNowCartModel =
                          OrderNowCartModel(
                        shopId: productDetails.product.shop.id,
                        shopName: productDetails.product.shop.name,
                        productId: productDetails.product.id,
                        price: productDetails.product.price,
                        discountPrice: productDetails.product.discountPrice,
                        productImage:
                            productDetails.product.thumbnails.first.thumbnail,
                        productName: productDetails.product.name,
                        size: productDetails.product.productSizeList.isNotEmpty
                            ? productDetails
                                .product
                                .productSizeList[
                                    ref.read(selectedProductSizeIndex)]
                                .name
                            : null,
                        color: productDetails.product.colors.isNotEmpty
                            ? productDetails
                                .product
                                .colors[ref.read(selectedProductColorIndex)!]
                                .name
                            : null,
                      );
                      if (!ref.read(hiveServiceProvider).userIsLoggedIn()) {
                        _showTheWarningDialog();
                      } else {
                        context.nav.pushNamed(
                          Routes.getOrderNowViewRouteName(
                              AppConstants.appServiceName),
                          arguments: orderNowCartModel,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _showTheWarningDialog() {
    showDialog(
      barrierColor: colors(GlobalFunction.navigatorKey.currentContext!)
          .accentColor!
          .withOpacity(0.8),
      context: GlobalFunction.navigatorKey.currentContext!,
      builder: (_) => ConfirmationDialog(
        title: S.of(context).youAreNotLoggedIn,
        confirmButtonText:
            S.of(GlobalFunction.navigatorKey.currentContext!).login,
        onPressed: () {
          GlobalFunction.navigatorKey.currentContext!.nav
              .pushNamedAndRemoveUntil(Routes.login, (route) => false);
        },
      ),
    );
  }
}

class LoadingWrapperWidget extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  const LoadingWrapperWidget({
    Key? key,
    required this.child,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const Opacity(
            opacity: 0.3,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (isLoading)
          const Center(
            child: AppLogo(
              withAppName: false,
              isAnimation: true,
            ),
          ),
      ],
    );
  }
}
