// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ready_ecommerce/components/ecommerce/increment_decrement_button.dart';
import 'package:ready_ecommerce/config/app_color.dart';
import 'package:ready_ecommerce/config/app_text_style.dart';
import 'package:ready_ecommerce/config/theme.dart';
import 'package:ready_ecommerce/controllers/common/master_controller.dart';
import 'package:ready_ecommerce/models/eCommerce/order/order_now_cart_model.dart';
import 'package:ready_ecommerce/utils/global_function.dart';

class OrderNowCartProduct extends StatelessWidget {
  final OrderNowCartModel product;
  final void Function()? increment;
  final void Function()? decrement;
  final int productQuantity;
  const OrderNowCartProduct({
    Key? key,
    required this.product,
    this.increment,
    this.decrement,
    required this.productQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5.h),
      child: Material(
        color: GlobalFunction.getContainerColor(),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors(context).accentColor!,
                width: 2.0,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImage(
                    productImage: product.productImage,
                  ),
                  Gap(16.w),
                  _buildProductInfo(
                    context: context,
                    product: product,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage({required String productImage}) {
    return Flexible(
      flex: 1,
      child: Container(
        width: 64.w,
        height: 64.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          image: DecorationImage(
            image: CachedNetworkImageProvider(
              productImage,
              errorListener: (error) => debugPrint(error.toString()),
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo({
    required BuildContext context,
    required OrderNowCartModel product,
  }) {
    return Flexible(
      flex: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.productName,
                  style: AppTextStyle(context)
                      .bodyText
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 12.sp),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Gap(6.h),
          _buildProductBottomRow(
            context: context,
            product: product,
          ),
          Gap(8.h),
          IncrementDecrementButton(
            productQuantity: productQuantity,
            increment: increment,
            decrement: decrement,
          ),
        ],
      ),
    );
  }

  Widget _buildProductBottomRow({
    required BuildContext context,
    required OrderNowCartModel product,
  }) {
    return Consumer(builder: (context, ref, _) {
      return Row(
        children: [
          Text(
            "${ref.read(masterControllerProvider.notifier).materModel.data.currency.symbol}${product.price}",
            style: AppTextStyle(context).bodyText.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors(context).primaryColor,
                ),
          ),
          Visibility(
            visible: product.discountPrice > 0,
            child: Row(
              children: [
                Gap(2.w),
                Text(
                  "${ref.read(masterControllerProvider.notifier).materModel.data.currency.symbol}${product.discountPrice.toString()}",
                  style: AppTextStyle(context).bodyText.copyWith(
                        fontSize: 12.sp,
                        color: EcommerceAppColor.lightGray,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: EcommerceAppColor.lightGray,
                      ),
                ),
              ],
            ),
          ),
          Gap(8.w),
          Visibility(
            visible: product.color != null,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5.w,
                vertical: 3.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: colors(context).accentColor,
              ),
              child: Center(
                child: Text(
                  product.color ?? '',
                  style: AppTextStyle(context).bodyTextSmall,
                ),
              ),
            ),
          ),
          Gap(8.w),
          Visibility(
            visible: product.size != null,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5.w,
                vertical: 3.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: EcommerceAppColor.offWhite,
              ),
              child: Center(
                child: Text(
                  product.size ?? '',
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: EcommerceAppColor.black,
                      ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
